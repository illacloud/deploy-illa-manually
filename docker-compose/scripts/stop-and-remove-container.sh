#!/usr/bin/env bash

echo
echo 'stopping container.'
echo

docker stop illa-backend
docker stop illa-backend-ws
docker stop illa-frontend
docker stop illa-database

docker ps 

echo
echo 'removing container.'
echo

docker rm illa-backend
docker rm illa-backend-ws
docker rm illa-frontend
docker rm illa-database

docker images

echo
echo 'done.'
echo
