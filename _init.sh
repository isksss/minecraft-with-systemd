#!/bin/bash

##############################################
# env
##############################################

# プロジェクト変数
export PAPERMC_PROJECT="${PAPERMC_PROJECT:-"paper"}"
export PAPERMC_VERSION="${PAPERMC_VERSION:-"1.21.1"}"
export MCHOME="/paper"
export JAR_FILE="$MCHOME/server.jar"
export PAPERMC_URL="https://api.papermc.io/v2/projects/${PAPERMC_PROJECT}/versions/${PAPERMC_VERSION}"

# 作業環境
export TEMP_DIR=$(mktemp -d)

##############################################
# func
##############################################
echo-r() {
    echo "#=============================="
    echo "# $@"
    echo "#=============================="
}

##############################################
# init
##############################################
# sudoをnopasswdで
{
    echo "$(whoami) ALL=(ALL) NOPASSWD: ALL"
} | sudo tee -a /etc/sudoers >> /dev/null

# インストール
echo-r "install java etc..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git curl openjdk-21-jdk jq netcat-traditional vim

# paperディレクトリが存在しない場合
if [ ! -d "$MCHOME" ]; then
    cd $TEMP_DIR
    git clone https://github.com/isksss/minecraft-with-systemd.git ./paper
    chown paper:paper ./paper
    sudo mv "./paper" "$MCHOME"
    # 環境変数ファイルを作成
    cp $MCHOME/.env_sample $MCHOME/.env
fi

cd $MCHOME

# タイムゾーンを設定
echo-r "set timezone"
sudo timedatectl set-timezone Asia/Tokyo

# サービスを追加する
echo-r "copy service and timer"
sudo cp -f $MCHOME/minecraft.service /etc/systemd/system/minecraft.service
sudo cp -f $MCHOME/minecraft.timer /etc/systemd/system/minecraft.timer

# jar fileをダウンロードする
echo-r "download project"
echo-r "project: ${PAPERMC_PROJECT}, version:${PAPERMC_VERSION}"
LATEST_BUILD=$(curl -H 'accept: application/json' -fsSL ${PAPERMC_URL} | jq '.builds[-1]')
DOWNLOAD_URL="${PAPERMC_URL}/builds/${LATEST_BUILD}/downloads/${PAPERMC_PROJECT}-${PAPERMC_VERSION}-${LATEST_BUILD}.jar"
echo-r ${DOWNLOAD_URL}
curl -fsSL $DOWNLOAD_URL -o $JAR_FILE

# サービス
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl enable --now minecraft.timer

sudo systemctl start minecraft.service

echo-r "status service"
sudo systemctl status minecraft.service
echo-r "status timer"
sudo systemctl status minecraft.timer
