#!/bin/bash
set -e

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading voipiran/voiz-contact-center from GitHub..."
if ! curl -fsSL https://github.com/voipiran/voiz-contact-center/archive/main.tar.gz | tar -xz -C "$TMPDIR"; then
    echo "Failed to download and extract the archive."
    exit 1
fi

CONTACT_CENTER_DIR="$TMPDIR/voiz-contact-center-main"

if [ ! -f "$CONTACT_CENTER_DIR/contactcenter.sh" ]; then
    echo "Error: contactcenter.sh not found in the downloaded archive."
    exit 1
fi

# Fix OS detection syntax error
sed -i 's/echo -e "${RED}Unsupported OS ($ID $VERSION_ID).${NC}"/echo -e "${RED}Unsupported OS: $ID $VERSION_ID${NC}"/' "$CONTACT_CENTER_DIR/contactcenter.sh"

# Fix the platform detection: add ISSABEL_VERSION and change the echo line
sed -i '/OS_FAMILY="el8"/a \    ISSABEL_VERSION=5' "$CONTACT_CENTER_DIR/contactcenter.sh"
sed -i '/OS_FAMILY="el7"/a \    ISSABEL_VERSION=4' "$CONTACT_CENTER_DIR/contactcenter.sh"
sed -i 's/echo -e "${YELLOW}Detected platform: ${BOLD}${OS_FAMILY^^}${NC}  (Issabel.*/echo -e "${YELLOW}Detected platform: ${BOLD}${OS_FAMILY^^}${NC}  (Issabel $ISSABEL_VERSION)"/' "$CONTACT_CENTER_DIR/contactcenter.sh"

echo "Running the ContactCenter installer..."
bash "$CONTACT_CENTER_DIR/contactcenter.sh"
