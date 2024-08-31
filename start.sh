#!/usr/bin/env sh
SCRIPT_DIR=$(
    cd $(dirname $0)
    pwd
)
source $SCRIPT_DIR/.env

# server.jar download
echo "PROJECT:${PAPER_PROJECT}, VERSION:${PAPER_VERSION}"
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/${PAPER_PROJECT}/versions/${PAPER_VERSION}/builds |
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

if [ "$LATEST_BUILD" != "null" ]; then
    JAR_NAME=${PAPER_PROJECT}-${PAPER_VERSION}-${LATEST_BUILD}.jar
    PAPERMC_URL="https://api.papermc.io/v2/projects/${PAPER_PROJECT}/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

    # Download the latest Paper version
    curl -o server.jar $PAPERMC_URL
    echo "Download completed"
else
    echo "No stable build for version $MINECRAFT_VERSION found :("
fi

# run
java -Xms${MEMORY} -Xmx${MEMORY} -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui