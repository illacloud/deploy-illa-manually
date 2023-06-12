#!/usr/bin/env bash

echo 
echo 'stop and remove illa-builder.'
echo

docker stop illa_builder_local
docker rm illa_builder_local

echo 
echo 'done.'
echo
