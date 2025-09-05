#!/bin/bash
# RDP Start Script for Investigation Container

echo "Starting Investigation Container RDP Session..."

# Start xrdp service manually (since systemctl doesn't work in containers)
/usr/sbin/xrdp-sesman --nodaemon &
/usr/sbin/xrdp --nodaemon &

# Wait a moment for services to start
sleep 3

# Set up desktop environment
mkdir -p /home/investigator/.config/autostart
mkdir -p /home/investigator/Desktop

# Copy desktop file to autostart and desktop
cp /home/investigator/tools/investigation-container.desktop /home/investigator/.config/autostart/
cp /home/investigator/tools/investigation-container.desktop /home/investigator/Desktop/
chmod +x /home/investigator/Desktop/investigation-container.desktop

# Create desktop shortcuts for common tools
cat > /home/investigator/Desktop/file-manager.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=File Manager
Comment=Browse files and folders
Exec=thunar
Icon=folder
Terminal=false
Categories=System;FileManager;
EOF

cat > /home/investigator/Desktop/terminal.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Command line interface
Exec=xfce4-terminal
Icon=terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF

cat > /home/investigator/Desktop/firefox.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox Web Browser
Comment=Browse the web safely
Exec=firefox
Icon=firefox
Terminal=false
Categories=Network;WebBrowser;
EOF

# Make desktop files executable
chmod +x /home/investigator/Desktop/*.desktop

# Set XFCE as the session manager
echo "xfce4-session" > /home/investigator/.xsession

# Display connection information
echo "========================================"
echo "  Investigation Container RDP Ready"
echo "========================================"
echo ""
echo "To connect via RDP:"
echo "  Host: localhost (or container IP)"
echo "  Port: 3389"
echo "  Username: investigator"
echo "  Password: investigate2024"
echo ""
echo "RDP service is running. Connect using any RDP client."
echo "========================================"

# Keep the container running
tail -f /dev/null