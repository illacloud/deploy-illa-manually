#!/bin/bash

echo
echo 'building illa all-in-one docker image.'
echo

docker build ./ -f ./illa-builder.dockerfile -t illa-builder:latest --no-cache

echo
echo '------------------------------------------------------------------------------------------------------'
echo

docker images | grep --color 'illa-builder'

echo
echo 'done.'
echo
