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

# Fix the unsupported OS line: remove parentheses and the dot
sed -i 's|echo -e "${RED}Unsupported OS ($ID $VERSION_ID).${NC}"|echo -e "${RED}Unsupported OS: $ID $VERSION_ID${NC}"|' "$CONTACT_CENTER_DIR/contactcenter.sh"

# Fix the platform line: replace the subshell with $ISSABEL_VERSION
sed -i 's|echo -e "${YELLOW}Detected platform: ${BOLD}${OS_FAMILY^^}${NC}  (Issabel $( [[ $OS_FAMILY == "el8" ]] && echo 5 || echo 4 ))"|echo -e "${YELLOW}Detected platform: ${BOLD}${OS_FAMILY^^}${NC}  (Issabel $ISSABEL_VERSION)"|' "$CONTACT_CENTER_DIR/contactcenter.sh"

# Add ISSABEL_VERSION after OS_FAMILY="el8"
sed -i '/OS_FAMILY="el8"/a \    ISSABEL_VERSION=5' "$CONTACT_CENTER_DIR/contactcenter.sh"
# Add ISSABEL_VERSION after OS_FAMILY="el7"
sed -i '/OS_FAMILY="el7"/a \    ISSABEL_VERSION=4' "$CONTACT_CENTER_DIR/contactcenter.sh"

echo "Running the ContactCenter installer..."
bash "$CONTACT_CENTER_DIR/contactcenter.sh"
