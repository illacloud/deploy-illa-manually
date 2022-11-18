#!/bin/sh

/opt/illa/database/postgres-init.sh &

/opt/illa/database/postgres-entrypoint.sh 

gosu postgres postgres & 

# loop
while true; do
    sleep 1;
done
