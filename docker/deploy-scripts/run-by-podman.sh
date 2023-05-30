#!/usr/bin/env bash

# config here
ILLA_HOME_DIR=~/illa
PG_VOLUMN=${ILLA_HOME_DIR}/database
DRIVE_VOLUMN=${ILLA_HOME_DIR}/drive



# init
mkdir -p ${ILLA_HOME_DIR}
mkdir -p ${PG_VOLUMN}
mkdir -p ${DRIVE_VOLUMN}

# run
podman run -d \
    --name illa-builder \
    -v $PG_VOLUMN:/opt/illa/database \
    -v $DRIVE_VOLUMN:/opt/illa/drive \
    -p 80:2022 \
    illasoft/illa-builder:latest 








