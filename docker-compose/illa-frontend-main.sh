#!/usr/bin/env bash

/opt/illa/illa-frontend-config-init.sh

nginx &

# loop
while true; do
    sleep 1;
done
