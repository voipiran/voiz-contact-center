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

echo "Running the ContactCenter installer..."
bash "$CONTACT_CENTER_DIR/contactcenter.sh"