#!/usr/bin/dumb-init /bin/bash

/opt/illa/config-init.sh

/opt/illa/database/postgres-init.sh &

/opt/illa/database/postgres-entrypoint.sh 

gosu postgres postgres & 
/opt/illa/builder-backend/bin/illa-backend &
/opt/illa/builder-backend/bin/illa-backend-ws &
nginx &

# loop
while true; do
    sleep 1;
done
