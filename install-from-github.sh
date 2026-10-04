#!/usr/bin/env bash

set -Eeuo pipefail

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="${VOIPIRAN_REPO_URL:-https://github.com/voipiran/voiz-contact-center.git}"
REPO_BRANCH="${VOIPIRAN_REPO_BRANCH:-main}"
PACKAGE_DIR="${VOIPIRAN_PACKAGE_DIR:-/opt/voipiran-contactcenter-installer}"
MAIN_INSTALLER="$PACKAGE_DIR/install.sh"
PATCH_SCRIPT="$PACKAGE_DIR/voipiran-patch/apply.sh"

log() {
    echo -e "${BLUE}[VOIPIRAN]${NC} $*"
}

fail() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    exit 1
}

if [[ "$(id -u)" -ne 0 ]]; then
    fail "This installer must be run as root."
fi

if [[ ! -f /etc/issabel.conf ]]; then
    fail "Issabel was not detected: /etc/issabel.conf was not found."
fi

for command in git bash; do
    command -v "$command" >/dev/null 2>&1 || fail "Required command is missing: $command"
done

if [[ -e "$PACKAGE_DIR" && ! -d "$PACKAGE_DIR" ]]; then
    fail "Package path exists but is not a directory: $PACKAGE_DIR"
fi

if [[ -d "$PACKAGE_DIR/.git" ]]; then
    log "Using the existing package checkout: $PACKAGE_DIR"
elif [[ -d "$PACKAGE_DIR" && -n "$(find "$PACKAGE_DIR" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    fail "Package path is not an empty Git checkout: $PACKAGE_DIR"
else
    log "Downloading ContactCenter from $REPO_URL"
    mkdir -p "$(dirname "$PACKAGE_DIR")"
    git clone --depth 1 --branch "$REPO_BRANCH" --single-branch "$REPO_URL" "$PACKAGE_DIR"
fi

[[ -f "$MAIN_INSTALLER" ]] || fail "Main installer was not found: $MAIN_INSTALLER"
[[ -f "$PATCH_SCRIPT" ]] || fail "Customization script was not found: $PATCH_SCRIPT"

chmod +x "$MAIN_INSTALLER" "$PATCH_SCRIPT"

log "Running the bundled OpDesk installer."
bash "$MAIN_INSTALLER"

log "Applying VOIPIRAN customizations."
bash "$PATCH_SCRIPT"

log "ContactCenter installation completed."
