#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Slaviša Arežina (tremor021)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/excalidraw/excalidraw-room

APP="Excalidraw Room"
TAGS="diagrams,collaboration"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources

    if [[ ! -d /opt/excalidraw-room ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    msg_info "Stopping $APP"
    systemctl stop excalidraw-room
    msg_ok "Stopped $APP"

    msg_info "Updating $APP"
    cd /opt/excalidraw-room
    $STD git pull
    $STD yarn install
    $STD yarn build
    ROOM_VERSION=$(grep -m1 "version" package.json | cut -d'"' -f4)
    echo "${ROOM_VERSION}" >/opt/excalidraw-room_version.txt
    msg_ok "Updated $APP to v${ROOM_VERSION}"

    msg_info "Starting $APP"
    systemctl start excalidraw-room
    msg_ok "Started $APP"

    msg_ok "Update Successful"
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:80${CL}"
