#!/bin/bash
SCRIPT_DIR=$(
    cd $(dirname $0)
    pwd
)

export PAPERMC_PROJECT="velocity"
export PAPERMC_VERSION="3.3.0-SNAPSHOT"

export MCHOME="/paper"
export JAR_FILE="$MCHOME/server.jar"
export PAPERMC_URL="https://api.papermc.io/v2/projects/${PAPERMC_PROJECT}/versions/${PAPERMC_VERSION}"

echo-r() {
    echo "=============================="
    echo "$@"
    echo "=============================="
}

echo-r "set timezone"
sudo timedatectl set-timezone Asia/Tokyo

echo-r "install java etc..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git curl openjdk-21-jdk jq netcat-traditional

echo-r "copy service and timer"
sudo cp $SCRIPT_DIR/minecraft.service /etc/systemd/system/minecraft.service
sudo cp $SCRIPT_DIR/minecraft.timer /etc/systemd/system/minecraft.timer

echo-r "download project"
echo-r "project: ${PAPERMC_PROJECT}, version:${PAPERMC_VERSION}"
LATEST_BUILD=$(curl -H 'accept: application/json' -fsSL ${PAPERMC_URL} | jq '.builds[-1]')
DOWNLOAD_URL="${PAPERMC_URL}/builds/${LATEST_BUILD}/downloads/${PAPERMC_PROJECT}-${PAPERMC_VERSION}-${LATEST_BUILD}.jar"
echo-r ${DOWNLOAD_URL}
curl -fsSL $DOWNLOAD_URL -o $JAR_FILE

sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl enable --now minecraft.timer

sudo systemctl start minecraft.service

echo-r "status service"
sudo systemctl status minecraft.service
echo-r "status timer"
sudo systemctl status minecraft.timer
