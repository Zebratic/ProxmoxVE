#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Slaviša Arežina (tremor021)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/excalidraw/excalidraw-room

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc \
  gnupg \
  xdg-utils \
  git
msg_ok "Installed Dependencies"

msg_info "Setup Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Setup Node.js Repository"

msg_info "Setup Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install -g yarn
msg_ok "Setup Node.js"

msg_info "Setup Excalidraw Room"
$STD git clone https://github.com/excalidraw/excalidraw-room.git /opt/excalidraw-room
cd /opt/excalidraw-room
$STD yarn install
$STD yarn build
ROOM_VERSION=$(grep -m1 "version" package.json | cut -d'"' -f4)
echo "${ROOM_VERSION}" >/opt/excalidraw-room_version.txt
msg_ok "Setup Excalidraw Room"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/excalidraw-room.service
[Unit]
Description=Excalidraw Room Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/excalidraw-room
ExecStart=/usr/bin/yarn start
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now excalidraw-room
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"