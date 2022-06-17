#!/usr/bin/env bash

# Install requires packages.
sudo yum install -y tar

# Download and install the headless server.
curl -sL https://www.factorio.com/get-download/${version}/headless/linux64 | sudo tar -xJ -C /opt

# Change file permisions and user.
sudo adduser factorio
sudo chown -R factorio:factorio /opt/factorio
sudo su - factorio

# In the factorio directory, create a new save file and start the server.
cd /opt/factorio
./bin/x64/factorio --create ./saves/factorio.zip
./bin/x64/factorio --start-server ./saves/factorio.zip --server-settings ./data/server-settings.json
