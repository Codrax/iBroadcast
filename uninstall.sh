#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

echo "Uninstalling iBroadcast..."

# Delete
rm -f /bin/ibroadcast
rm -rf /usr/lib/ibroadcast/
rm -rf /usr/share/ibroadcast/

# Remove shortcut
rm -f /usr/share/applications/ibroadcast.desktop

# Remove icons
rm -rf /usr/share/icons/hicolor/*/apps/ibroadcast.*
rm -rf /usr/share/icons/hicolor/*/mimetypes/ibroadcast.*

# Refresh icon cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f /usr/share/icons/hicolor/ 2>/dev/null || true
fi

echo "Uninstalled successfully!"
