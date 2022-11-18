#!/usr/bin/env bash


# config here
ILLA_HOME_DIR=/var/lib/illa
PG_VOLUMN=${ILLA_HOME_DIR}/database/postgresql


# init
mkdir -p ${ILLA_HOME_DIR}
mkdir -p ${PG_VOLUMN}
mkdir -p ${ILLA_HOME_DIR}
chmod 0777 ${PG_VOLUMN} # @todo: chmod for MacOS, the gid is "wheel", not "root". and we will fix this later.

# run
docker compose -f ./docker-compose.yml up -d 
sleep 3
docker compose -f ./docker-compose.yml ps 

