#!/bin/bash

#docker compose safe
#if command -v docker-compose &>/dev/null
#then docker_compose="docker-compose"
#elif docker --help | grep -q "compose"
#then docker_compose="docker compose"
#fi

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
docker_status=$(docker inspect shardeum-dashboard | jq -r .[].State.Status)
folder_size=$(du -hs $HOME/.shardeum | awk '{print $1}')
port=$(cat ~/.shardeum/.env | grep SHMEXT | cut -d "=" -f 2)
version=$(curl -s http://localhost:$port/nodeinfo | jq .nodeInfo.appData.shardeumVersion | sed 's/\"//g')
node_status=$(curl -s http://localhost:$port/nodeinfo | jq .nodeInfo.status | sed 's/"//g')

case $node_status in
 null) status="ok";note="standby ($note_status)" ;;
 active) status="ok";note="active" ;;
 *) status="error";note="API error ($note_status)" ;;
esac

case $docker_status in
  running) ;;
  *) status="error"; note="docker not running" ;;
esac

cat << EOF
{
  "project":"$folder",
  "id":$SHARDEUM_ID,
  "machine":"$MACHINE",
  "chain":"sphinx",
  "type":"node",
  "status":"$status",
  "note":"$note",
  "folder_size":"$folder_size",
  "updated":"$(date --utc +%FT%TZ)",
  "docker_status":"$docker_status",
  "node_status":"$node_status",
  "port":"$port",
  "version":"$version"
}
EOF
