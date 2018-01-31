#!/bin/bash

printf "\n################## Setup web application ##################\n"

# Install third parties
npm install

# Create the directory of the web application
mkdir -p "$openvpn_admin"
cp -r "$base_path/"{app/,public/,vendor/,.env} "$openvpn_admin"

chown -R "$user:$group" "$openvpn_admin"
