#!/usr/bin/dumb-init /bin/bash

echo
echo '______  __        __         ______         _______   __    __  ______  __        _______   ________  _______     '
echo '/      |/  |      /  |       /      \       /       \ /  |  /  |/      |/  |      /       \ /        |/       \   '
echo '$$$$$$/ $$ |      $$ |      /$$$$$$  |      $$$$$$$  |$$ |  $$ |$$$$$$/ $$ |      $$$$$$$  |$$$$$$$$/ $$$$$$$  |  '
echo '  $$ |  $$ |      $$ |      $$ |__$$ |      $$ |__$$ |$$ |  $$ |  $$ |  $$ |      $$ |  $$ |$$ |__    $$ |__$$ |  '
echo '  $$ |  $$ |      $$ |      $$    $$ |      $$    $$< $$ |  $$ |  $$ |  $$ |      $$ |  $$ |$$    |   $$    $$<   '
echo '  $$ |  $$ |      $$ |      $$$$$$$$ |      $$$$$$$  |$$ |  $$ |  $$ |  $$ |      $$ |  $$ |$$$$$/    $$$$$$$  |  '
echo ' _$$ |_ $$ |_____ $$ |_____ $$ |  $$ |      $$ |__$$ |$$ \__$$ | _$$ |_ $$ |_____ $$ |__$$ |$$ |_____ $$ |  $$ |  '
echo '/ $$   |$$       |$$       |$$ |  $$ |      $$    $$/ $$    $$/ / $$   |$$       |$$    $$/ $$       |$$ |  $$ |  '
echo '$$$$$$/ $$$$$$$$/ $$$$$$$$/ $$/   $$/       $$$$$$$/   $$$$$$/  $$$$$$/ $$$$$$$$/ $$$$$$$/  $$$$$$$$/ $$/   $$/   '
echo                                                                                                            

# init
echo
echo '[init]'
echo
/opt/illa/config-init.sh

# run entrypoint files
echo
echo '[run entrypoint files]'
echo
/opt/illa/database/postgres-entrypoint.sh 
/opt/illa/minio/minio-entrypoint.sh 
/opt/illa/envoy/envoy-entrypoint.sh

# run postgres
echo
echo '[run postgres]'
echo
gosu postgres postgres & 

# run minio
echo
echo '[run minio]'
echo
gosu minio /usr/local/bin/minio server /opt/illa/drive/ &

# init data
echo
echo '[init data]'
echo
/opt/illa/database/postgres-init.sh 

# run illa units
echo
echo '[run illa units]'
echo
/opt/illa/illa-builder-backend/bin/illa-builder-backend &
/opt/illa/illa-builder-backend/bin/illa-builder-backend-ws &
/opt/illa/illa-supervisor-backend/bin/illa-supervisor-backend &
/opt/illa/illa-supervisor-backend/bin/illa-supervisor-backend-internal &

# run ingress and gateway
echo
echo '[run ingress and gateway]'
echo
nginx &
gosu envoy /usr/local/bin/envoy -c /opt/illa/envoy/illa-unit-ingress.yaml &


# loop
while true; do
    sleep 1;
done
