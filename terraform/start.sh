#!/usr/bin/env bash

# Install requires packages.
sudo yum install -y tar

# Create factorio user and install dir.
sudo mkdir /opt/factorio
sudo adduser factorio
sudo chown factorio:factorio /opt/factorio

# Download and install the headless server.
sudo su - factorio
curl -sL https://www.factorio.com/get-download/${version}/headless/linux64 | tar -xJ -C /opt

# In the factorio directory, create a new save file and start the server.
cd /opt/factorio
./bin/x64/factorio --create ./saves/factorio.zip
./bin/x64/factorio --start-server ./saves/factorio.zip
