#!/bin/bash

# Configuration
SCRIPT_NAME="audio-monitor.sh"
SERVICE_NAME="audio-monitor.service"
BIN_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "--- Audio Monitor Installer ---"

# 1. Create directories if they don't exist
mkdir -p "$BIN_DIR"
mkdir -p "$SERVICE_DIR"

# 2. Check if the monitor script exists in the current folder
if [ ! -f "$SCRIPT_NAME" ]; then
    echo "Error: $SCRIPT_NAME not found in the current directory."
    exit 1
fi

# 3. Copy the script and make it executable
cp "$SCRIPT_NAME" "$BIN_DIR/"
chmod +x "$BIN_DIR/$SCRIPT_NAME"
echo "✓ Script moved to $BIN_DIR"

# 4. Create the systemd service file dynamically
cat <<EOF > "$SERVICE_DIR/$SERVICE_NAME"
[Unit]
Description=Auto Audio Profile Switcher
After=pipewire.service

[Service]
Type=simple
ExecStart=/bin/bash $BIN_DIR/$SCRIPT_NAME
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

echo "✓ Service file created at $SERVICE_DIR"

# 5. Reload systemd and start the service
echo "--- Starting Service ---"
systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"
systemctl --user restart "$SERVICE_NAME"

echo "--- Success ---"
systemctl --user status "$SERVICE_NAME" --no-pager
