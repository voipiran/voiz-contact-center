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

# Fix the unsupported OS line
LINE_UNSUPPORTED=$(grep -n "Unsupported OS (\$ID \$VERSION_ID)" "$CONTACT_CENTER_DIR/contactcenter.sh" | cut -d: -f1)
if [ ! -z "$LINE_UNSUPPORTED" ]; then
    sed -i "${LINE_UNSUPPORTED}s/.*/    echo -e \"\${RED}Unsupported OS: \$ID \$VERSION_ID\${NC}\"/" "$CONTACT_CENTER_DIR/contactcenter.sh"
fi

# Fix the platform line
LINE_PLATFORM=$(grep -n "Detected platform: \${BOLD}\${OS_FAMILY^^}\${NC}  (Issabel" "$CONTACT_CENTER_DIR/contactcenter.sh" | cut -d: -f1)
if [ ! -z "$LINE_PLATFORM" ]; then
    sed -i "${LINE_PLATFORM}s/.*/    echo -e \"\${YELLOW}Detected platform: \${BOLD}\${OS_FAMILY^^}\${NC}  (Issabel \$ISSABEL_VERSION)\"/" "$CONTACT_CENTER_DIR/contactcenter.sh"
fi

# Fix the OS_FAMILY lines to add ISSABEL_VERSION
# First, handle the el7 block (which comes after el8 in the file)
LINE_EL7=$(grep -n 'OS_FAMILY="el7"' "$CONTACT_CENTER_DIR/contactcenter.sh" | cut -d: -f1)
if [ ! -z "$LINE_EL7" ]; then
    sed -i "${LINE_EL7}s/OS_FAMILY=\"el7\"/OS_FAMILY=\"el7\"\n    ISSABEL_VERSION=4/" "$CONTACT_CENTER_DIR/contactcenter.sh"
fi

# Then, handle the el8 block
LINE_EL8=$(grep -n 'OS_FAMILY="el8"' "$CONTACT_CENTER_DIR/contactcenter.sh" | cut -d: -f1)
if [ ! -z "$LINE_EL8" ]; then
    sed -i "${LINE_EL8}s/OS_FAMILY=\"el8\"/OS_FAMILY=\"el8\"\n    ISSABEL_VERSION=5/" "$CONTACT_CENTER_DIR/contactcenter.sh"
fi

echo "Running the ContactCenter installer..."
bash "$CONTACT_CENTER_DIR/contactcenter.sh"
