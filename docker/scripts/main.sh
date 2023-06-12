#!/usr/bin/env bash

# define color output
BLACK='\033[0;30m'     
DARKGRAY='\033[1;30m'
RED='\033[0;31m'     
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'     
LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'           
YELLOW='\033[1;33m'
BLUE='\033[0;34m'     
LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'     
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'     
LIGHTCYAN='\033[1;36m'
LIGHTGRAY='\033[0;37m'      
WHITE='\033[1;37m'
NC='\033[0m' # No Color

_label() {
    while read -r l; do
        echo "$1 $l"
    done
}

#
# Let's Rock !!!
#

echo
echo -e "${LIGHTBLUE}██╗██╗     ██╗      █████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗  ${NC}"
echo -e "${LIGHTBLUE}██║██║     ██║     ██╔══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗ ${NC}"
echo -e "${LIGHTBLUE}██║██║     ██║     ███████║    ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝ ${NC}"
echo -e "${LIGHTBLUE}██║██║     ██║     ██╔══██║    ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗ ${NC}"
echo -e "${LIGHTBLUE}██║███████╗███████╗██║  ██║    ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║ ${NC}"
echo -e "${LIGHTBLUE}╚═╝╚══════╝╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝ ${NC}"
echo 
echo                                                                                   

# default config
export PGDATA=/opt/illa/database/pgdata 
export MINIODATA=/opt/illa/drive/


# init function
current_user="$(id -u)"


#
# run pre init scripts
#
echo
echo -e "${LIGHTBLUE}[run pre init scripts]${NC}"
echo
/opt/illa/pre-init.sh

#
# run entrypoint scripts
#
echo
echo -e "${LIGHTBLUE}[run entrypoint scripts]${NC}"
echo
/opt/illa/postgres/postgres-entrypoint.sh 2>&1 | _label "[postgres entrypoint] "
/opt/illa/redis/redis-entrypoint.sh 2>&1 | _label "[redis entrypoint] "
/opt/illa/minio/minio-entrypoint.sh 2>&1 | _label "[minio entrypoint] "
/opt/illa/nginx/nginx-entrypoint.sh 2>&1 | _label "[nginx entrypoint] "
/opt/illa/envoy/envoy-entrypoint.sh 2>&1 | _label "[envoy entrypoint] "

# run postgres
echo
echo -e "${LIGHTBLUE}[run postgres]${NC}"
echo
if [ $current_user = '0' ]; then
    gosu postgres postgres 2>&1 | _label "[postgres] " & 
else
    postgres 2>&1 | _label "[postgres] " & 
fi

# init data
echo
echo -e "${LIGHTBLUE}[init data]${NC}"
echo
/opt/illa/postgres/postgres-init.sh 2>&1 | _label "[data init scripts] "


#
# run redis-server
#
echo
echo -e "${LIGHTBLUE}[run redis-server]${NC}"
echo
redis-server 2>&1 | _label "[redis] " & 


#
# run minio
#
echo
echo -e "${LIGHTBLUE}[run minio]${NC}"
echo
/usr/local/bin/minio server $MINIODATA 2>&1 | _label "[minio] "  &


# run illa units
echo
echo -e "${LIGHTBLUE}[run illa units]${NC}"
echo
/opt/illa/illa-builder-backend/bin/illa-builder-backend 2>&1 | _label "[illa-builder-backend] " &
/opt/illa/illa-builder-backend/bin/illa-builder-backend-ws 2>&1 | _label "[illa-builder-backend-ws] " &
/opt/illa/illa-supervisor-backend/bin/illa-supervisor-backend 2>&1 | _label "[illa-supervisor-backend] " &
/opt/illa/illa-supervisor-backend/bin/illa-supervisor-backend-internal 2>&1 | _label "[illa-supervisor-backend-internal] "  &

#
# run nginx
#
echo
echo -e "${LIGHTBLUE}[run nginx]${NC}"
echo
nginx -e /dev/stderr 2>&1 | _label "[nginx] "  &


#
# run envoy
#
echo
echo -e "${LIGHTBLUE}[run envoy]${NC}"
echo
if [ $current_user = '0' ]; then
    gosu envoy /usr/local/bin/envoy -c /opt/illa/envoy/illa-unit-ingress.yaml 2>&1 | _label "[envoy] "   &
else
    /usr/local/bin/envoy -c /opt/illa/envoy/illa-unit-ingress.yaml 2>&1 | _label "[envoy] "   &
fi


#
# run post init scripts
#
echo
echo -e "${LIGHTBLUE}[run post init scripts]${NC}"
echo
/opt/illa/post-init.sh

# loop
while true; do
    sleep 1;
done


