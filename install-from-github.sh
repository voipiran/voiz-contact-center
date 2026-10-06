#!/usr/bin/env bash

set -Eeuo pipefail

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="${VOIPIRAN_REPO_URL:-https://github.com/voipiran/voipiran-ContactCenter.git}"
REPO_BRANCH="${VOIPIRAN_REPO_BRANCH:-main}"
PACKAGE_DIR="${VOIPIRAN_PACKAGE_DIR:-/opt/voipiran-contactcenter-installer}"
MAIN_INSTALLER="$PACKAGE_DIR/install.sh"
PATCH_SCRIPT="$PACKAGE_DIR/voipiran-patch/apply.sh"

log()  { echo -e "${BLUE}[VOIPIRAN]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# Must be root
[[ "$(id -u)" -eq 0 ]] || fail "This installer must be run as root."

# Must be Issabel
[[ -f /etc/issabel.conf ]] || fail "Issabel not detected: /etc/issabel.conf missing."

# Required commands
for cmd in git bash curl; do
    command -v "$cmd" >/dev/null 2>&1 || fail "Required command missing: $cmd"
done

# Validate install dir
if [[ -e "$PACKAGE_DIR" && ! -d "$PACKAGE_DIR" ]]; then
    fail "Package path exists but is not a directory: $PACKAGE_DIR"
fi

# Clone or update repo
if [[ -d "$PACKAGE_DIR/.git" ]]; then
    log "Using existing package checkout: $PACKAGE_DIR"
    cd "$PACKAGE_DIR"
    git fetch origin
    git reset --hard "origin/$REPO_BRANCH"
else
    if [[ -d "$PACKAGE_DIR" && -n "$(find "$PACKAGE_DIR" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
        fail "Package path is not empty and not a git repo: $PACKAGE_DIR"
    fi
    log "Downloading ContactCenter from $REPO_URL (branch: $REPO_BRANCH)..."
    mkdir -p "$(dirname "$PACKAGE_DIR")"
    git clone --depth 1 --branch "$REPO_BRANCH" --single-branch "$REPO_URL" "$PACKAGE_DIR"
fi

[[ -f "$MAIN_INSTALLER" ]] || fail "Main installer not found: $MAIN_INSTALLER"
[[ -f "$PATCH_SCRIPT" ]] || fail "Customization script not found: $PATCH_SCRIPT"

chmod +x "$MAIN_INSTALLER" "$PATCH_SCRIPT"

# ============================================================
# PRE-INSTALL FIXES (run BEFORE main installer)
# ============================================================

# 1. Ensure python symlink exists BEFORE installer runs (fixes "python: command not found")
if ! command -v python >/dev/null 2>&1; then
    PY311=$(command -v python3.11 || command -v python3.12 || command -v python3.13 || command -v python3)
    if [[ -n "$PY311" && -f "$PY311" ]]; then
        ln -sf "$PY311" /usr/local/bin/python
        ln -sf "${PY311/python/pip}" /usr/local/bin/pip 2>/dev/null || true
        ok "Created python/pip symlinks to $PY311"
    else
        warn "Python 3.11+ not found; installer will attempt to install it"
    fi
fi

# 2. Fix nginx default config conflict with httpd (port 80/443)
# The OpDesk installer creates nginx config on 9001/8080, but nginx package installs default.conf on 80/443
if [[ -f /etc/nginx/conf.d/default.conf ]]; then
    log "Removing nginx default.conf (conflicts with httpd on 80/443)..."
    rm -f /etc/nginx/conf.d/default.conf
fi

# 3. Preserve FreePBX AMI admin secret (Apply Config breaks if changed from amp111)
if [[ -f /etc/asterisk/manager.conf ]]; then
    if grep -q '^\[admin\]' /etc/asterisk/manager.conf; then
        CURRENT_SECRET=$(sed -n '/^\[admin\]/,/^\[/p' /etc/asterisk/manager.conf | grep '^secret =' | head -1 | cut -d'=' -f2 | xargs)
        if [[ "$CURRENT_SECRET" != "amp111" ]]; then
            warn "Restoring AMI admin secret to 'amp111' for FreePBX Apply Config compatibility"
            sed -i '/^\[admin\]/,/^\[/ s/^secret =.*/secret = amp111/' /etc/asterisk/manager.conf
            asterisk -rx "manager reload" >/dev/null 2>&1 || true
        fi
    fi
fi

# 4. Ensure firewall allows port 9001
if systemctl is-active --quiet firewalld 2>/dev/null; then
    firewall-cmd --add-port=9001/tcp --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    ok "Firewall: opened port 9001"
elif command -v iptables >/dev/null 2>&1; then
    iptables -I INPUT -p tcp --dport 9001 -j ACCEPT 2>/dev/null || true
    service iptables save 2>/dev/null || true
    ok "iptables: opened port 9001"
fi

# ============================================================
# RUN INSTALLERS
# ============================================================

log "Running the bundled OpDesk installer."
bash "$MAIN_INSTALLER"

log "Applying VOIPIRAN customizations."
bash "$PATCH_SCRIPT"

log "ContactCenter installation completed."