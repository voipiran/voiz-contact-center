#!/bin/bash


#Install ChanSPY
DB_USER=""
DB_PASS=""
DB_HOST="127.0.0.1"
DB_NAME="asterisk"

if [[ -f /etc/issabel.conf ]]; then
  # Issabel
  echo -e "${CYAN}Detected Issabel...${NC}"
  rootpw=$(sed -ne 's/.*mysqlrootpwd=//p' /etc/issabel.conf | tr -d '[:space:]')
  if [[ -n "${rootpw:-}" ]]; then
    DB_USER="root"
    DB_PASS="$rootpw"
    DB_NAME="asterisk"
  fi
fi

if [[ -z "$DB_PASS" && -f /etc/freepbx.conf ]]; then
  # FreePBX (Ø¬Ø¯ÛŒØ¯)
  echo -e "${CYAN}Detected FreePBX (freepbx.conf)...${NC}"
  amp_user=$(grep -Po "(?<=amp_conf\['AMPDBUSER'\]\s*=\s*')[^']+" /etc/freepbx.conf | head -n1)
  amp_pass=$(grep -Po "(?<=amp_conf\['AMPDBPASS'\]\s*=\s*')[^']+" /etc/freepbx.conf | head -n1)
  amp_host=$(grep -Po "(?<=amp_conf\['AMPDBHOST'\]\s*=\s*')[^']+" /etc/freepbx.conf | head -n1)
  amp_name=$(grep -Po "(?<=amp_conf\['AMPDBNAME'\]\s*=\s*')[^']+" /etc/freepbx.conf | head -n1)

  [[ -n "$amp_user" ]] && DB_USER="$amp_user"
  [[ -n "$amp_pass" ]] && DB_PASS="$amp_pass"
  [[ -n "$amp_host" ]] && DB_HOST="$amp_host"
  [[ -n "$amp_name" ]] && DB_NAME="$amp_name"
fi

if [[ -z "$DB_PASS" && -f /etc/amportal.conf ]]; then
  # FreePBX (Ù‚Ø¯ÛŒÙ…ÛŒ)
  echo -e "${CYAN}Detected FreePBX (amportal.conf legacy)...${NC}"
  amp_user=$(awk -F= '/^AMPDBUSER/ {print $2}' /etc/amportal.conf | tr -d '[:space:]')
  amp_pass=$(awk -F= '/^AMPDBPASS/ {print $2}' /etc/amportal.conf | tr -d '[:space:]')
  amp_host=$(awk -F= '/^AMPDBHOST/ {print $2}' /etc/amportal.conf | tr -d '[:space:]')
  amp_name=$(awk -F= '/^AMPDBNAME/ {print $2}' /etc/amportal.conf | tr -d '[:space:]')

  [[ -n "$amp_user" ]] && DB_USER="$amp_user"
  [[ -n "$amp_pass" ]] && DB_PASS="$amp_pass"
  [[ -n "$amp_host" ]] && DB_HOST="$amp_host"
  [[ -n "$amp_name" ]] && DB_NAME="$amp_name"
fi

if [[ -z "$DB_PASS" && -f /root/.my.cnf ]]; then
  # Ø§Ú¯Ø± root .my.cnf Ù…ÙˆØ¬ÙˆØ¯ Ø§Ø³Øª
  echo -e "${CYAN}Using /root/.my.cnf credentials...${NC}"
  rootpw=$(awk -F= '/^[[:space:]]*password[[:space:]]*=/ {print $2}' /root/.my.cnf | tr -d '[:space:]')
  if [[ -n "${rootpw:-}" ]]; then
    DB_USER="root"
    DB_PASS="$rootpw"
  fi
fi

if [[ -z "$DB_USER" || -z "$DB_PASS" ]]; then
  echo -e "${YELLOW}Could not auto-detect DB credentials. Please enter manually.${NC}"
  read -rp "MySQL username (default root): " tmpu
  read -srp "MySQL password: " tmpp; echo
  [[ -n "${tmpu:-}" ]] && DB_USER="$tmpu" || DB_USER="root"
  DB_PASS="$tmpp"
fi

echo -e "DB user: ${GREEN}${DB_USER}${NC}"
echo -e "DB host: ${GREEN}${DB_HOST}${NC}"
echo -e "DB name: ${GREEN}${DB_NAME}${NC}"

# ------------------------------
# 2) Ø§ÙØ²ÙˆØ¯Ù† Ú©Ø§Ù†ØªÚ©Ø³Øª Ùˆ Ø§ÛŒÙ†Ú©Ù„ÙˆØ¯ Ø¯Ø± extensions_custom.conf
# ------------------------------
FILE="/etc/asterisk/extensions_custom.conf"
LINE="[from-internal-custom]"

# Ø§Ú¯Ø± Ø³Ú©Ø´Ù† ÙˆØ¬ÙˆØ¯ Ù†Ø¯Ø§Ø±Ø¯ØŒ Ø§Ø¶Ø§ÙÙ‡â€ŒØ§Ø´ Ú©Ù†
if ! grep -qF "$LINE" "$FILE" 2>/dev/null; then
  echo -e "${YELLOW}Adding [from-internal-custom] to ${FILE}${NC}"
  echo "$LINE" | sudo tee -a "$FILE" >/dev/null
fi

# include => voipiran-chanspypro Ø±Ø§ Ø¨Ø¹Ø¯ Ø§Ø² Ø³Ú©Ø´Ù† Ø§Ø¶Ø§ÙÙ‡ Ú©Ù† Ø§Ú¯Ø± Ù†Ø¨ÙˆØ¯
if grep -qF "include => voipiran-chanspypro" "$FILE" 2>/dev/null; then
  echo -e "${GREEN}include => voipiran-chanspypro already exists${NC}"
else
  echo -e "${YELLOW}Adding include => voipiran-chanspypro${NC}"
  sudo sed -i '/\[from-internal-custom\]/a include => voipiran-chanspypro' "$FILE"
fi

# Ø®ÙˆØ¯ Ú©Ø§Ù†ØªÚ©Ø³Øª voipiran-chanspypro Ø§Ú¯Ø± Ù†ÛŒØ³ØªØŒ Ø§Ø¶Ø§ÙÙ‡ Ú©Ù†
if grep -qF "[voipiran-chanspypro]" "$FILE" 2>/dev/null; then
  echo -e "${GREEN}[voipiran-chanspypro] already exists${NC}"
else
  echo -e "${YELLOW}Appending [voipiran-chanspypro] context${NC}"

  cat <<'EOD' | sudo tee -a "$FILE" >/dev/null
[voipiran-chanspypro]
;; voipiran.io - Hamed Kouhfallah
;; ChanSpy Pro - SIP / PJSIP compatible
;; Uses Issabel device database to resolve the actual channel technology.

;; ÙÙ‚Ø· Ø´Ù†ÛŒØ¯Ù†
exten => _*30X.,1,Set(DEV=${DB(AMPUSER/${EXTEN:3}/device)})
 same => n,Set(DEV=${CUT(DEV,&,1)})
 same => n,Set(CHAN=${DB(DEVICE/${DEV}/dial)})
 same => n,ChanSpy(${CHAN},Eq)

;; ÙÙ‚Ø· Ø´Ù†ÛŒØ¯Ù† - Only listen to audio coming from this channel
exten => _*31X.,1,Set(DEV=${DB(AMPUSER/${EXTEN:3}/device)})
 same => n,Set(DEV=${CUT(DEV,&,1)})
 same => n,Set(CHAN=${DB(DEVICE/${DEV}/dial)})
 same => n,ChanSpy(${CHAN},Eqo)

;; Whisper Ø¨Ù‡ Agent
exten => _*32X.,1,Set(DEV=${DB(AMPUSER/${EXTEN:3}/device)})
 same => n,Set(DEV=${CUT(DEV,&,1)})
 same => n,Set(CHAN=${DB(DEVICE/${DEV}/dial)})
 same => n,ChanSpy(${CHAN},Eqw)

;; Private Whisper
exten => _*33X.,1,Set(DEV=${DB(AMPUSER/${EXTEN:3}/device)})
 same => n,Set(DEV=${CUT(DEV,&,1)})
 same => n,Set(CHAN=${DB(DEVICE/${DEV}/dial)})
 same => n,ChanSpy(${CHAN},EqW)

;; Barge-in
exten => _*34X.,1,Set(DEV=${DB(AMPUSER/${EXTEN:3}/device)})
 same => n,Set(DEV=${CUT(DEV,&,1)})
 same => n,Set(CHAN=${DB(DEVICE/${DEV}/dial)})
 same => n,ChanSpy(${CHAN},EqB)

;; DTMF switchable
exten => _*35X.,1,Set(DEV=${DB(AMPUSER/${EXTEN:3}/device)})
 same => n,Set(DEV=${CUT(DEV,&,1)})
 same => n,Set(CHAN=${DB(DEVICE/${DEV}/dial)})
 same => n,ChanSpy(${CHAN},Eqd)
EOD
fi

# ------------------------------
# 3) Ø¯Ø±Ø¬/Ø¨Ù‡â€ŒØ±ÙˆØ²Ø±Ø³Ø§Ù†ÛŒ Feature Codes Ø¯Ø± Ø¯ÛŒØªØ§Ø¨ÛŒØ³
# Ø¬Ø¯ÙˆÙ„: featurecodes  (FreePBX/Issabel Ù‡Ø±Ø¯Ùˆ)
# ------------------------------
run_query () {
  local sql="$1"
  mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$sql" >/dev/null 2>&1
  return $?
}

echo -e "${CYAN}Updating feature codes...${NC}"

# Ø´Ù†ÙˆØ¯ Ø³Ø§Ø¯Ù‡
run_query "INSERT INTO featurecodes (modulename, featurename, description, defaultcode, customcode, enabled, providedest)
VALUES ('core','ChanSpy-Simple','Ø´Ù†ÙˆØ¯ Ø³Ø§Ø¯Ù‡ØŒ Ú©Ø¯ + Ø¯Ø§Ø®Ù„ÛŒ','*30',NULL,'1','1')
ON DUPLICATE KEY UPDATE defaultcode='*30', enabled='1';"

# ÙÙ‚Ø· ØµØ¯Ø§ÛŒ Ú©Ø§Ø±Ø´Ù†Ø§Ø³
run_query "INSERT INTO featurecodes (modulename, featurename, description, defaultcode, customcode, enabled, providedest)
VALUES ('core','ChanSpy-OnlyListen','ÙÙ‚Ø· ØµØ¯Ø§ÛŒ Ú©Ø§Ø±Ø´Ù†Ø§Ø³ØŒ Ú©Ø¯ + Ø¯Ø§Ø®Ù„ÛŒ','*31',NULL,'1','1')
ON DUPLICATE KEY UPDATE defaultcode='*31', enabled='1';"

# Ø´Ù†ÙˆØ¯ + Ù†Ø¬ÙˆØ§ (Whisper)
run_query "INSERT INTO featurecodes (modulename, featurename, description, defaultcode, customcode, enabled, providedest)
VALUES ('core','ChanSpy-Whisper','Ø´Ù†ÙˆØ¯ Ùˆ ØµØ­Ø¨Øª Ù¾Ù†Ù‡Ø§Ù†ÛŒØŒ Ú©Ø¯ + Ø¯Ø§Ø®Ù„ÛŒ','*32',NULL,'1','1')
ON DUPLICATE KEY UPDATE defaultcode='*32', enabled='1';"

# Ù†Ø¬ÙˆØ§ Ø®ØµÙˆØµÛŒ
run_query "INSERT INTO featurecodes (modulename, featurename, description, defaultcode, customcode, enabled, providedest)
VALUES ('core','ChanSpy-PrivateWhisper','ØµØ­Ø¨Øª Ø¨Ø§ Ú©Ø§Ø±Ø´Ù†Ø§Ø³ Ø¨Ø¯ÙˆÙ† Ø´Ù†ÛŒØ¯Ù† Ù…Ø´ØªØ±ÛŒØŒ Ú©Ø¯ + Ø¯Ø§Ø®Ù„ÛŒ','*33',NULL,'1','1')
ON DUPLICATE KEY UPDATE defaultcode='*33', enabled='1';"

# Barge
run_query "INSERT INTO featurecodes (modulename, featurename, description, defaultcode, customcode, enabled, providedest)
VALUES ('core','ChanSpy-Barge','Ø´Ù†ÙˆØ¯ Ùˆ Ù…Ú©Ø§Ù„Ù…Ù‡ Ø¨Ø§ Ù‡Ø± Ω�Ùˆ Ω·Ø±ÙØŒ Ú©Ø¯ + Ω�Ø§Ø®Ù„ÛŒ','*34',NULL,'1','1')
ON DUPLICATE KEY UPDATE defaultcode='*34', enabled='1';"

# DTMF Mode Change
run_query "INSERT INTO featurecodes (modulename, featurename, description, defaultcode, customcode, enabled, providedest)
VALUES ('core','ChanSpy-DTMF','ØªØºÛŒÛŒØ± Ω­Ø§Ù„Øª Ω´Ù†ÙˆØ¯ Ω­ÛŒÙ† ΩªÙ…Ø§Ø³ Ω¨Ø§ Ú©Ù„ÛŒØ¯ 4/5/6ØŒ Ú©Ø¯ + Ω�Ø§Ø®Ù„ÛŒ','*35',NULL,'1','1')
ON DUPLICATE KEY UPDATE defaultcode='*35', enabled='1';"





# Responsibilities:
#   1. Install VOIPIRAN ContactCenter RPM dependencies
#   2. Install VOIPIRAN ContactCenter Python dependencies
#   3. Run the main OpDesk install.sh
#   4. Verify /opt/OpDesk
#   5. Apply VOIPIRAN customizations
#   6. Reload Asterisk and restart Apache

set -e

PROJECT_ROOT="/opt/OpDesk"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# VOIPIRAN ContactCenter paths
PATCH_ROOT="$SCRIPT_DIR/voipiran-patch"
MAIN_INSTALLER="$SCRIPT_DIR/install.sh"

# RPM dependencies
RPM_BASE_URL="https://voipiran.io/clover/contactcenter-rpms"
RPM_DIR="/tmp/contactcenter-rpms"

# Python Wheel dependencies
WHEEL_BASE_URL="https://voipiran.io/clover/contactcenter-wheels"
WHEEL_DIR="/tmp/contactcenter-wheels"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'


echo ""
echo "====================================="
echo "Install VOIPIRAN ContactCenter"
echo "VOIPIRAN.io"
echo "====================================="
echo ""


# ===============================================================
# 1. Root check
# ===============================================================

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}ERROR: This installer must be run as root.${NC}"
    exit 1
fi


# ===============================================================
# 2. Check Issabel
# ===============================================================

if [ ! -f /etc/issabel.conf ]; then
    echo -e "${RED}ERROR: /etc/issabel.conf was not found.${NC}"
    echo "This installer is intended for Issabel."
    exit 1
fi


# ===============================================================
# 3. Get Issabel MySQL root password
# ===============================================================

rootpw=$(sed -ne 's/.*mysqlrootpwd=//gp' /etc/issabel.conf)

if [ -z "$rootpw" ]; then
    echo -e "${RED}ERROR: Could not read mysqlrootpwd from /etc/issabel.conf${NC}"
    exit 1
fi

echo -e "${GREEN}Issabel MySQL root password detected.${NC}"


# Detect Platform (Issabel 4/5)
source /etc/os-release
if [[ "$ID" =~ (rocky|almalinux|rhel|centos) && "${VERSION_ID%%.*}" == "8" ]]; then
  OS_FAMILY="el8"
  ISSABEL_VERSION=5
elif [[ "$ID" =~ (centos|rhel) && "${VERSION_ID%%.*}" == "7" ]]; then
  OS_FAMILY="el7"
  ISSABEL_VERSION=4
else
  echo -e "${RED}Unsupported OS: $ID $VERSION_ID${NC}"
  exit 1
fi
echo -e "${YELLOW}Detected platform: ${BOLD}${OS_FAMILY^^}${NC}  (Issabel $ISSABEL_VERSION)"


# ===============================================================
# 4. Install ContactCenter RPM Dependencies
# ===============================================================

echo ""
echo "====================================="
echo "Installing ContactCenter RPM Dependencies"
echo "====================================="
echo ""

rm -rf "$RPM_DIR"
mkdir -p "$RPM_DIR"

echo "Downloading RPM manifest..."

curl -fsSL -k \
    "${RPM_BASE_URL}/manifest.txt" \
    -o "$RPM_DIR/manifest.txt" || {
        echo -e "${RED}Failed to download ContactCenter RPM manifest!${NC}"
        exit 1
    }


if [ ! -s "$RPM_DIR/manifest.txt" ]; then
    echo -e "${RED}ContactCenter RPM manifest is empty!${NC}"
    exit 1
fi


echo ""
echo "Downloading RPM packages..."
echo ""

while IFS= read -r rpm_file || [ -n "$rpm_file" ]; do

    rpm_file=$(echo "$rpm_file" | tr -d '\r')

    # Ignore empty lines and comments
    [[ -z "$rpm_file" || "$rpm_file" =~ ^# ]] && continue

    echo "Downloading: $rpm_file"

    curl -fsSL -k \
        "${RPM_BASE_URL}/${rpm_file}" \
        -o "$RPM_DIR/$rpm_file" || {
            echo -e "${RED}Failed to download: $rpm_file${NC}"
            exit 1
        }

    if [ ! -s "$RPM_DIR/$rpm_file" ]; then
        echo -e "${RED}Downloaded RPM is empty: $rpm_file${NC}"
        exit 1
    fi

done < "$RPM_DIR/manifest.txt"


echo ""
echo "Installing ContactCenter RPM packages..."
echo ""

dnf install -y \
    --disablerepo="*" \
    "$RPM_DIR"/*.rpm || {
        echo -e "${RED}Failed to install ContactCenter RPM packages!${NC}"
        exit 1
    }


# Verify Python 3.11

if ! command -v python3.11 >/dev/null 2>&1; then
    echo -e "${RED}ERROR: Python 3.11 was not installed successfully!${NC}"
    exit 1
fi


echo ""
echo "Python version:"
python3.11 --version

rm -rf "$RPM_DIR"

echo ""
echo -e "${GREEN}ContactCenter RPM dependencies installed successfully.${NC}"


# ===============================================================
# 5. Install ContactCenter Python Dependencies
# ===============================================================

echo ""
echo "====================================="
echo "Installing ContactCenter Python Dependencies"
echo "====================================="
echo ""

rm -rf "$WHEEL_DIR"
mkdir -p "$WHEEL_DIR"

echo "Downloading Python wheel manifest..."

curl -fsSL -k \
    "${WHEEL_BASE_URL}/manifest.txt" \
    -o "$WHEEL_DIR/manifest.txt" || {
        echo -e "${RED}Failed to download ContactCenter wheel manifest!${NC}"
        exit 1
    }


if [ ! -s "$WHEEL_DIR/manifest.txt" ]; then
    echo -e "${RED}ContactCenter wheel manifest is empty!${NC}"
    exit 1
fi


echo ""
echo "Downloading Python wheel packages..."
echo ""

while IFS= read -r wheel_file || [ -n "$wheel_file" ]; do

    wheel_file=$(echo "$wheel_file" | tr -d '\r')

    # Ignore empty lines and comments
    [[ -z "$wheel_file" || "$wheel_file" =~ ^# ]] && continue

    echo "Downloading: $wheel_file"

    curl -fsSL -k \
        "${WHEEL_BASE_URL}/${wheel_file}" \
        -o "$WHEEL_DIR/$wheel_file" || {
            echo -e "${RED}Failed to download wheel: $wheel_file${NC}"
            exit 1
        }

    if [ ! -s "$WHEEL_DIR/$wheel_file" ]; then
        echo -e "${RED}Downloaded wheel is empty: $wheel_file${NC}"
        exit 1
    fi

done < "$WHEEL_DIR/manifest.txt"


echo ""
echo "Installing Python packages offline..."
echo ""

python3.11 -m pip install \
    --no-index \
    --no-cache-dir \
    "$WHEEL_DIR"/*.whl || {
        echo -e "${RED}ContactCenter Python dependencies installation failed!${NC}"
        exit 1
    }


echo ""
echo "Verifying ContactCenter Python dependencies..."
echo ""

python3.11 -c "
import dotenv
import mysql.connector
import fastapi
import uvicorn
import websockets
import httpx
import jwt
import bcrypt
import openpyxl
import google.auth
import h2
import cryptography
import webrtcvad
import onnxruntime
" || {
    echo -e "${RED}ContactCenter Python dependencies verification failed!${NC}"
    exit 1
}


rm -rf "$WHEEL_DIR"

echo ""
echo -e "${GREEN}ContactCenter Python dependencies installed successfully.${NC}"


# ===============================================================
# 7. Install & Configure Nginx (EL8 only)
# ===============================================================
if [[ "$OS_FAMILY" == "el8" ]]; then
  echo -e "${CYAN}Installing nginx (offline RPMs)...${NC}"
  TMP_DIR="/tmp/nginx-rpms"; mkdir -p "$TMP_DIR"
  BASE_URL="http://voipiran.io/clover/nginx-rpms"
  NGINX_FS_RPM="nginx-filesystem-1.14.1-9.module+el8.4.0+542+81547229.noarch.rpm"
  NGINX_RPM="nginx-1.14.1-9.module+el8.4.0+542+81547229.x86_64.rpm"
  for f in "$NGINX_FS_RPM" "$NGINX_RPM"; do
    echo -e "${YELLOW}âž¡ï¸  $f${NC}"
    curl -s -L "${BASE_URL}/${f}" -o "$TMP_DIR/$f" || { echo -e "${RED}Download failed: $f${NC}"; exit 1; }
    [[ -s "$TMP_DIR/$f" ]] || { echo -e "${RED}Empty file: $f${NC}"; exit 1; }
  done

  if ! dnf install -y --disablerepo="*" "$TMP_DIR/$NGINX_FS_RPM"; then
    echo -e "${YELLOW}Offline nginx-filesystem install failed, enabling AminIDC as fallback...${NC}"
    dnf install -y \
      --disablerepo="*" \
      --enablerepo=rocky-baseos,rocky-appstream \
      "$TMP_DIR/$NGINX_FS_RPM" || { echo -e "${RED}nginx-filesystem install failed${NC}"; exit 1; }
  fi

  # The Rocky module build of nginx formally Requires "nginx-all-modules" (mail/stream/perl/...
  # xslt/image-filter), but those are all compiled as dynamic modules nginx only loads via an
  # explicit `load_module` directive in nginx.conf, which we never use. Pulling in that whole
  # chain would mean installing a full perl interpreter + a graphics library stack for nothing,
  # and risks version conflicts with what Issabel/Asterisk already rely on. --nodeps skips that
  # bookkeeping-only dependency; the core nginx binary runs standalone (verified: config test +
  # actual HTTP response with only these two packages installed).
  if ! rpm -q nginx >/dev/null 2>&1; then
    rpm -Uvh --nodeps "$TMP_DIR/$NGINX_RPM" || { echo -e "${RED}nginx install failed${NC}"; exit 1; }
  else
    echo -e "${GREEN}nginx is already installed; skipping RPM installation.${NC}"
  fi

  rm -rf "$TMP_DIR"
  command -v nginx >/dev/null 2>&1 || { echo -e "${RED}nginx command not found after install${NC}"; exit 1; }
  id nginx >/dev/null 2>&1 || { echo -e "${RED}nginx system user missing after install${NC}"; exit 1; }

  # ===============================================================
  # 8. Move Nginx Default Port 80 To 8080
  # ===============================================================
  echo -e "${CYAN}Changing nginx default port from 80 to 8080...${NC}"

  if [[ -f /etc/nginx/nginx.conf ]]; then
    sed -i \
      -e 's/listen[[:space:]]\+80 default_server;/listen 8080 default_server;/g' \
      -e 's/listen[[:space:]]\+\[::\]:80 default_server;/listen [::]:8080 default_server;/g' \
      /etc/nginx/nginx.conf
  fi

  if [[ -f /etc/nginx/conf.d/default.conf ]]; then
    sed -i \
      -e 's/listen[[:space:]]\+80;/listen 8080;/g' \
      -e 's/listen[[:space:]]\+\[::\]:80;/listen [::]:8080;/g' \
      /etc/nginx/conf.d/default.conf
  fi

  echo -e "${GREEN}nginx default port changed to 8080.${NC}"

  # Only systems running PHP 8.3 (Remi) behind nginx need the PHP-FPM pool handover.
  # Standard Issabel 5 (PHP 7.4 + Apache) must keep its system pool untouched,
  # otherwise the Issabel web interface would break.

  PHP_POOL="/etc/opt/remi/php83/php-fpm.d/www.conf"

  if [ ! -f "$PHP_POOL" ] && [ -f "${PHP_POOL}.bak" ]; then
      cp -f "${PHP_POOL}.bak" "$PHP_POOL"
  fi

  if [ ! -f "$PHP_POOL" ]; then
    echo -e "${YELLOW}PHP 8.3 (Remi) pool not found; skipping PHP-FPM handover (not needed by OpDesk).${NC}"
    systemctl daemon-reload
    systemctl enable nginx
    echo -e "${GREEN}nginx installed.${NC}"
  else
  sed -i \
    -e 's|^user = .*|user = nginx|' \
    -e 's|^group = .*|group = nginx|' \
    -e 's|^listen = .*|listen = /var/opt/remi/php83/run/php-fpm/www.sock|' \
    -e 's|^[[:space:]]*listen\.acl_users[[:space:]]*=.*|;listen.acl_users =|' \
    -e 's|^[[:space:]]*listen\.acl_groups[[:space:]]*=.*|;listen.acl_groups =|' \
    -e '/^listen\.allowed_clients/d' \
    -e '/^listen\.owner/d' \
    -e '/^listen\.group/d' \
    -e '/^listen\.mode/d' \
    "$PHP_POOL"

  grep -q '^listen.owner' "$PHP_POOL" || echo "listen.owner = nginx" >> "$PHP_POOL"
  grep -q '^listen.group' "$PHP_POOL" || echo "listen.group = nginx" >> "$PHP_POOL"
  grep -q '^listen.mode' "$PHP_POOL"  || echo "listen.mode = 0660" >> "$PHP_POOL"

  systemctl daemon-reload
  systemctl enable php83-php-fpm nginx
  echo -e "${GREEN}nginx installed and PHP-FPM pool handed over to it.${NC}"
  fi
fi


# ===============================================================
# 6. Run Main OpDesk Installer
# ===============================================================

if [ ! -f "$MAIN_INSTALLER" ]; then
    echo -e "${RED}ERROR: Main OpDesk install.sh was not found:${NC}"
    echo "$MAIN_INSTALLER"
    exit 1
fi


echo ""
echo "====================================="
echo "Running Main OpDesk Installer"
echo "====================================="
echo ""

chmod +x "$MAIN_INSTALLER"

bash "$MAIN_INSTALLER" || {
    echo -e "${RED}Main OpDesk installer failed!${NC}"
    exit 1
}


echo ""
echo -e "${GREEN}Main OpDesk installation completed successfully.${NC}"


# ===============================================================
# 7. Verify OpDesk Project
# ===============================================================

if [ ! -d "$PROJECT_ROOT" ]; then
    echo -e "${RED}ERROR: OpDesk project was not created:${NC}"
    echo "$PROJECT_ROOT"
    exit 1
fi


echo -e "${GREEN}OpDesk project found:${NC} $PROJECT_ROOT"


# ===============================================================
# 8. Apply VOIPIRAN Customizations
# ===============================================================

if [ ! -f "$PATCH_ROOT/apply.sh" ]; then
    echo -e "${RED}ERROR: VOIPIRAN apply.sh was not found:${NC}"
    echo "$PATCH_ROOT/apply.sh"
    exit 1
fi


echo ""
echo "====================================="
echo "Applying VOIPIRAN Customizations"
echo "====================================="
echo ""

chmod +x "$PATCH_ROOT/apply.sh"

"$PATCH_ROOT/apply.sh" || {
    echo -e "${RED}VOIPIRAN customization failed!${NC}"
    exit 1
}


echo ""
echo -e "${GREEN}VOIPIRAN customizations applied successfully.${NC}"


# ===============================================================
# 9. Restart Services
# ===============================================================

echo ""
echo "====================================="
echo "Restart Services"
echo "====================================="
echo ""

systemctl reload asterisk || true
systemctl restart httpd || true


# ===============================================================
# 10. Final Message
#
# IMPORTANT:
# Frontend build is intentionally manual.
# ===============================================================

echo ""
echo "====================================="
echo "VOIPIRAN ContactCenter Installed"
echo "====================================="
echo ""

echo -e "${GREEN}Installation completed successfully.${NC}"

echo ""
echo -e "${YELLOW}Frontend build was NOT performed.${NC}"

echo ""
echo "Build manually before starting OpDesk:"
echo ""
echo "  cd $PROJECT_ROOT/frontend"
echo "  npm run build"

echo ""
echo "Then start the service:"
echo ""
echo "  systemctl start opdesk"

echo ""