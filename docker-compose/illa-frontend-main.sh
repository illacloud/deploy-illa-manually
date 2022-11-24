#!/usr/bin/env bash

echo 
echo '////////////////////////////////////////////////////////////////'
echo '                   Running ILLA Frontend  Image                 '
echo '////////////////////////////////////////////////////////////////'
echo 

/opt/illa/illa-frontend-config-init.sh

nginx &

# loop
while true; do
    sleep 1;
done
