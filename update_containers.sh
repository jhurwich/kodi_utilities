#!/bin/bash

function usage {
  echo -e "USAGE: $0 <container_name> \n"
  exit 1
}

function log {
  echo -e "$(date +"%Y-%m-%d_%H:%M:%S") [UPDATE] $1"
}

function fail {
  log "ERROR '$1'"
  exit 1
}

container=$1
shift
if [[ -z $container ]]
  then
  usage
fi

if [[ "$container" != "radarr" && "$container" != "sabnzbd" && "$container" != "sonarr"  ]]
  then
  fail "unrecognized container '$container'"
fi

log "docker pull linuxserver/$container"
docker pull linuxserver/$container
if [[ $? -ge 1 ]]
  then
  fail "'docker pull linuxserver/$container' failed - res: $?"
fi

log "docker stop $container"
docker stop $container
if [[ $? -ge 1 ]]
  then
  fail "'docker stop $container' failed - res: $?"
fi

log "docker rm $container"
docker rm $container
if [[ $? -ge 1 ]]
  then
  fail "'docker rm $container' failed - res: $?"
fi

log "docker create --name=$container..."
if [[ "$container" == "radarr" ]]
  then
  docker create \
    --name=radarr \
    --restart=unless-stopped \
    --network=media_network \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Los_Angeles \
    -p 8383:8383 \
    -v /storage/docker/volumes/radarr/config:/config \
    -v /storage/docker/volumes/radarr/logs:/logs \
    -v /storage/data:/data \
    linuxserver/radarr
  if [[ $? -ge 1 ]]
    then
    fail "'docker create $container' failed - res: $?"
  fi

elif [[ "$container" == "sabnzbd" ]]
  then
  docker create \
    --name=sabnzbd \
    --restart=unless-stopped \
    --network=media_network \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Los_Angeles \
    -p 8181:8181 \
    -p 9191:9191 \
    -v /storage/docker/volumes/sabnzbd/config:/config \
    -v /storage/data/downloads:/data/downloads \
    -v /storage/data/incomplete:/data/incomplete \
    linuxserver/sabnzbd
  if [[ $? -ge 1 ]]
    then
    fail "'docker create $container' failed - res: $?"
  fi

elif [[ "$container" == "sonarr"  ]]
  then
  docker create \
    --name=sonarr \
    --restart=unless-stopped \
    --network=media_network \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Los_Angeles \
    -p 8282:8282 \
    -v /storage/docker/volumes/sonarr/config:/config \
    -v /storage/docker/volumes/sonarr/logs:/logs \
    -v /storage/data:/data \
    linuxserver/sonarr
  if [[ $? -ge 1 ]]
    then
    fail "'docker create $container' failed - res: $?"
  fi
fi

log "docker start $container"
docker start $container
if [[ $? -ge 1 ]]
  then
  fail "'docker start $container' failed - res: $?"
fi