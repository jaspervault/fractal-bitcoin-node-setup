#!/bin/bash

# Set default version and installation directory of fractald
DEFAULT_VERSION="0.2.2"
DEFAULT_INSTALL_DIR="/fb"

# Ask user for the version of fractald to install
echo "Enter the version of fractald you want to install (default is $DEFAULT_VERSION):"
read -p "Version [$DEFAULT_VERSION]: " VERSION
VERSION=${VERSION:-$DEFAULT_VERSION}

# Ask user for the installation directory
echo "Enter the installation directory (default is $DEFAULT_INSTALL_DIR):"
read -p "Installation Directory [$DEFAULT_INSTALL_DIR]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}

# Update system and install necessary packages
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl build-essential pkg-config libssl-dev git wget jq make gcc chrony -y

# Download and unpack the specified version of fractald
wget "https://github.com/fractal-bitcoin/fractald-release/releases/download/v$VERSION/fractald-$VERSION-x86_64-linux-gnu.tar.gz" || { echo "Failed to download fractald"; exit 1; }
tar -zxvf "fractald-$VERSION-x86_64-linux-gnu.tar.gz" || { echo "Failed to extract fractald"; exit 1; }

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Installation directory $INSTALL_DIR does not exist. Creating it..."
    sudo mkdir -p "$INSTALL_DIR" || { echo "Failed to create directory $INSTALL_DIR"; exit 1; }
fi

echo "Moving extracted directory..."

mv "fractald-$VERSION-x86_64-linux-gnu" "$INSTALL_DIR/" || { echo "Failed to move fractald to $INSTALL_DIR"; exit 1; }
cd "$INSTALL_DIR/fractald-$VERSION-x86_64-linux-gnu" || { echo "Failed to change directory"; exit 1; }
mkdir data
cp ./bitcoin.conf ./data

echo "Setting up systemd service..."

# Setup the systemd service
sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Bitcoin Node
After=network.target

[Service]
User=root
WorkingDirectory=$INSTALL_DIR/fractald-$VERSION-x86_64-linux-gnu
ExecStart=$INSTALL_DIR/fractald-$VERSION-x86_64-linux-gnu/bin/bitcoind -datadir=$INSTALL_DIR/fractald-$VERSION-x86_64-linux-gnu/data/ -maxtipage=504576000
Restart=always
RestartSec=3
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable fractald
sudo systemctl start fractald

echo "Setting up systemd service done!"

# Output logs
sudo journalctl -u fractald -o cat
