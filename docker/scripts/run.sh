#!/usr/bin/env bash

# config here
PG_PASS=mysecretpassword
ILLA_HOME_DIR=/var/lib/illa
PG_VOLUMN=${ILLA_HOME_DIR}/database/postgresql
API_SERVER_ADDRESS=localhost
WEBSOCKET_SERVER_ADDRESS=localhost
WEBSOCKER_PORT=8000



# init
mkdir -p ${ILLA_HOME_DIR}
mkdir -p ${PG_VOLUMN}
mkdir -p ${ILLA_HOME_DIR}
chmod 0777 ${PG_VOLUMN} # @todo: chmod for MacOS, the gid is "wheel", not "root". and we will fix this later.

# run
docker run -d \
    --name illa-builder \
    -e POSTGRES_PASSWORD=$PG_PASS \
    -e GIN_MODE=release \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -e API_SERVER_ADDRESS=$API_SERVER_ADDRESS \
    -e WEBSOCKET_SERVER_ADDRESS=$WEBSOCKET_SERVER_ADDRESS \
    -e WEBSOCKER_PORT=$WEBSOCKER_PORT \
    -v $PG_VOLUMN:/var/lib/postgresql/data \
    -p 5432:5432 \
    -p 80:80 \
    -p 8000:8000 \
    -p 9999:9999 \
    illa-builder:latest 





