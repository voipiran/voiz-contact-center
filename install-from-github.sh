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

# Fix the OS detection block by inserting ISSABEL_VERSION and fixing the echo lines
# Line numbers are based on the original script structure; we adjust for insertions.

# Insert ISSABEL_VERSION after OS_FAMILY="el8" (line 266) and after OS_FAMILY="el7" (line 268)
sed -i '266a \    ISSABEL_VERSION=5' "$CONTACT_CENTER_DIR/contactcenter.sh"
# After the first insertion, the original line 268 is now at line 269
sed -i '269a \    ISSABEL_VERSION=4' "$CONTACT_CENTER_DIR/contactcenter.sh"

# Fix the unsupported OS line (originally line 270, now line 272 after two insertions? Let's recalc:
# After two insertions, the line that was 270 is now at 272? Actually, we inserted two lines, so everything after 266 shifts by 2.
# But we inserted at 266 and 269, so the shift is not uniform.
# Instead, we can fix by pattern or by knowing that the unsupported OS line is the one after the else.
# We'll fix it by pattern to be safe.
sed -i 's|echo -e "\${RED}Unsupported OS (\$ID \$VERSION_ID)\.\${NC}"|echo -e "\${RED}Unsupported OS: \$ID \$VERSION_ID\${NC}|' "$CONTACT_CENTER_DIR/contactcenter.sh"

# Fix the platform line (we know it's the line with the subshell)
sed -i 's|echo -e "\${YELLOW}Detected platform: \${BOLD}\${OS_FAMILY^^}\${NC}  (Issabel \$([[ \$OS_FAMILY == "el8" ]] \&\& echo 5 || echo 4 ))"|echo -e "\${YELLOW}Detected platform: \${BOLD}\${OS_FAMILY^^}\${NC}  (Issabel \$ISSABEL_VERSION)"|' "$CONTACT_CENTER_DIR/contactcenter.sh"

echo "Running the ContactCenter installer..."
bash "$CONTACT_CENTER_DIR/contactcenter.sh"
