#!/usr/bin/env bash

# config here
ILLA_HOME_DIR=/var/lib/illa
PG_VOLUMN=${ILLA_HOME_DIR}/database/postgresql
DRIVE_VOLUMN=${ILLA_HOME_DIR}/drive



# init
mkdir -p ${ILLA_HOME_DIR}
mkdir -p ${PG_VOLUMN}
mkdir -p ${DRIVE_VOLUMN}
chmod 0777 ${PG_VOLUMN} # @todo: chmod for MacOS, the gid is "wheel", not "root". and we will fix this later.

# run
podman run -d \
    --name illa-builder \
    -e GIN_MODE=release \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v $PG_VOLUMN:/var/lib/postgresql/data \
    -v $DRIVE_VOLUMN:/opt/illa/drive \
    -p 80:80 \
    illasoft/illa-builder:latest 





