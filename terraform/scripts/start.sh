#!/usr/bin/env bash

set -e

# Init vars.
INSTALL_DIR="/opt/factorio"
BIN="$${INSTALL_DIR}/bin/x64/factorio"
S3="s3://${bucket}/factorio"
USER="factorio"

# Install required packages.
sudo yum install -y tar

# Download and install the headless server.
curl -sL https://www.factorio.com/get-download/${version}/headless/linux64 | sudo tar -xJ -C /opt
cd $${INSTALL_DIR}

# Configure settings files.
mv ./data/map-gen-settings.example.json ./data/map-gen-settings.json
mv ./data/map-settings.example.json ./data/map-settings.json
mv ./data/server-settings.example.json ./data/server-settings.json

# In the install directory, check S3 for an existing save file or create a new one.
if aws s3 ls $${S3}/saves/factorio.zip > /dev/null; then
	echo "Found existing save file in S3"
	aws s3 cp $${S3}/saves/factorio.zip ./saves/factorio.zip
else
	# Check S3 for existing map gen settings.
	if aws s3 ls $${S3}/data/map-gen-settings.json > /dev/null; then
		echo "Found existing map gen settings in S3"
		aws s3 cp $${S3}/data/map-gen-settings.json ./data/map-gen-settings.json
	fi
	# Check S3 for existing map settings.
	if aws s3 ls $${S3}/data/map-settings.json > /dev/null; then
		echo "Found existing map settings in S3"
		aws s3 cp $${S3}/data/map-settings.json ./data/map-settings.json
	fi

	echo "Creating new save file"
	$${BIN} --create ./saves/factorio.zip \
		--map-gen-settings ./data/map-gen-settings.json \
		--map-settings ./data/map-settings.json
fi

# Check S3 for server settings.
if aws s3 ls $${S3}/data/server-settings.json > /dev/null; then
	echo "Found existing server settings in S3"
	aws s3 cp $${S3}/data/server-settings.json ./data/server-settings.json
fi

# Change file permisions and create factorio user.
sudo adduser --system $${USER}
sudo chown -R $${USER}:$${USER} $${INSTALL_DIR}

# Create a systemd service for the headless server.
echo "[Unit]
Description=Factorio Headless Server

[Service]
Type=simple
User=$${USER}
ExecStart=$${BIN} --server-settings $${INSTALL_DIR}/data/server-settings.json --start-server-load-latest $${INSTALL_DIR}/saves/factorio.zip" | sudo tee /etc/systemd/system/factorio.service

# Create a systemd service for the backup service.
echo "[Unit]
Description=Sync Factorio saves to S3

[Service]
Type=oneshot
ExecStart=/usr/bin/aws s3 cp $${INSTALL_DIR}/saves/factorio.zip $${S3}/saves/factorio.zip" | sudo tee /etc/systemd/system/factorio-backup.service

# Create a systemd timer for backup service.
echo "[Unit]
Description=Run Factorio backup service every 15m

[Timer]
OnBootSec=900s
OnUnitActiveSec=900s

[Install]
WantedBy=timers.target" | sudo tee /etc/systemd/system/factorio-backup.timer

# Finally, start the server.
echo "Starting factorio server..."
sudo systemctl enable --now factorio.service factorio-backup.timer
