#!/bin/bash

##############################################
# env
##############################################

# プロジェクト変数
export MCHOME="/paper"
export JAR_FILE="$MCHOME/server.jar"

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
sudo apt install -y git curl openjdk-21-jdk jq vim

# paperディレクトリが存在しない場合
if [ ! -d "$MCHOME" ]; then
    cd $TEMP_DIR
    git clone https://github.com/isksss/minecraft-with-systemd.git ./paper
    chown paper:paper ./paper
    sudo mv "./paper" "$MCHOME"
fi

cd $MCHOME
if [ -f "$MCHOME/.env" ];then
    . "$MCHOME/.env"
else
    # 環境変数ファイルを作成
    cp $MCHOME/.env_sample $MCHOME/.env
    echo-r "edit .env"
    exit 1
fi

# タイムゾーンを設定
echo-r "set timezone"
sudo timedatectl set-timezone Asia/Tokyo
