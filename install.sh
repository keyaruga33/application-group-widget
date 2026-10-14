#!/usr/bin/env bash
set -e

PLUGIN_ID="com.keyaruga.applicationgroup"
PACKAGE_TYPE="Plasma/Applet"
SRC_DIR="src"
ICON_SRC="$SRC_DIR/contents/icons"
ICON_DEST="$HOME/.local/share/icons/hicolor"

echo "=== Application Group Widget Installer ==="

# Check kpackagetool6
if ! command -v kpackagetool6 &> /dev/null; then
    echo "ERROR: kpackagetool6 is not installed or not in PATH."
    exit 1
fi

# Install custom icons
echo "Installing custom icons..."
mkdir -p "$ICON_DEST/256x256/apps" "$ICON_DEST/128x128/apps" "$ICON_DEST/64x64/apps" "$ICON_DEST/48x48/apps" "$ICON_DEST/32x32/apps"
cp -f "$ICON_SRC/com.keyaruga.applicationgroup.png" "$ICON_DEST/256x256/apps/$PLUGIN_ID.png" 2>/dev/null || true
cp -f "$ICON_SRC/128x128.png" "$ICON_DEST/128x128/apps/$PLUGIN_ID.png" 2>/dev/null || true
cp -f "$ICON_SRC/64x64.png" "$ICON_DEST/64x64/apps/$PLUGIN_ID.png" 2>/dev/null || true
cp -f "$ICON_SRC/48x48.png" "$ICON_DEST/48x48/apps/$PLUGIN_ID.png" 2>/dev/null || true
cp -f "$ICON_SRC/32x32.png" "$ICON_DEST/32x32/apps/$PLUGIN_ID.png" 2>/dev/null || true
gtk-update-icon-cache -q -t "$ICON_DEST" 2>/dev/null || true

# Upgrade if already installed, otherwise install
echo "Installing / Upgrading $PLUGIN_ID..."
if kpackagetool6 --type "$PACKAGE_TYPE" --show "$PLUGIN_ID" &> /dev/null; then
    kpackagetool6 --type "$PACKAGE_TYPE" --upgrade "$SRC_DIR"
    echo "Successfully upgraded $PLUGIN_ID!"
else
    kpackagetool6 --type "$PACKAGE_TYPE" --install "$SRC_DIR"
    echo "Successfully installed $PLUGIN_ID!"
fi

echo
echo "To add the widget:"
echo "1. Right click on your Desktop or Panel -> 'Add Widgets...' (افزودن ویجت)"
echo "2. Search for 'Application Group' or 'گروه برنامه‌ها'"
echo "3. Drag and drop it to your Desktop or Panel!"
