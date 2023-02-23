#!/usr/bin/env bash

echo 
echo 'stop and remove illa-builder.'
echo

docker stop illa-builder
docker rm illa-builder

echo 
echo 'done.'
echo
