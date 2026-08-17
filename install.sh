#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

# Script
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

# Prepare
mkdir -p /usr/lib/ibroadcast/
mkdir -p /usr/share/ibroadcast/

# Copy
cp "$SCRIPT_DIR/iBroadcast" /bin/ibroadcast
cp -r "$SCRIPT_DIR/shared-lib-linux/"* /usr/lib/ibroadcast
cp -r "$SCRIPT_DIR/runtime/"* /usr/share/ibroadcast/

# Shortcut ...
cat > /usr/share/applications/ibroadcast.desktop <<'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=iBroadcast
GenericName=Music Player
Comment=Listen and manage your music library
Exec=ibroadcast %F
Icon=ibroadcast
Terminal=false
Categories=AudioVideo;Audio;Player;
StartupNotify=true
Keywords=Music;Player;iBroadcast

[Desktop Action OfflineMode]
Name=Offline mode
Exec=ibroadcast --offline
EOF

# Icons
cp -r "$SCRIPT_DIR/install/linux/hicolor/"* /usr/share/icons/hicolor/

# Perms
chmod 755 /usr/bin/ibroadcast
chmod -R a+rX /usr/share/ibroadcast/
chmod -R a+rX /usr/lib/ibroadcast/
chmod -R a+rX /usr/share/icons/hicolor/
chmod 644 /usr/share/applications/ibroadcast.desktop

# Done
echo "Installed successfuly!"
