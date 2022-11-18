#!/bin/bash



# build
docker build ./ -f ./illa-backend-ws.dockerfile -t illa-backend-ws:latest --no-cache
docker build ./ -f ./illa-backend.dockerfile -t illa-backend:latest --no-cache
docker build ./ -f ./illa-frontend.dockerfile -t illa-frontend:latest --no-cache
docker build ./ -f ./illa-database.dockerfile -t illa-database:latest --no-cache

echo
echo '------------------------------------------------------------------------------------------------------'
echo

docker images | grep --color 'illa'

echo
echo 'done.'
echo
