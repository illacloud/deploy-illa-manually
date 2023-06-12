#!/usr/bin/env bash
set -Eeo pipefail

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

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}



_check_process() {
    ret=$(ps -aux | grep "$1" | grep -v grep)
    if [ ${#ret} -gt 0 ]; then
        readarray -t result <<<"$ret"
        for i in "${result[@]}"
        do
           echo -e "${GREEN}├─  $i${NC}"
        done
    else
        echo -e "${RED}├─ [x] can not found process \"$1\".${NC}"
    fi
}
    

_main() {
    # watting process start
    sleep 10 

    echo 
    echo -e "${LIGHTBLUE}[checkout post init status]${NC}"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess postgres]${NC}"
    echo "$(_check_process 'postgres')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess redis]${NC}"
    echo "$(_check_process 'redis-server')"
    echo 
    
    echo -e "${LIGHTBLUE}┌[checking porcess minio]${NC}"
    echo "$(_check_process 'minio')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess envoy]${NC}"
    echo "$(_check_process 'envoy')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess nginx]${NC}"
    echo "$(_check_process 'nginx')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess illa-builder-backend]${NC}"
    echo "$(_check_process 'illa-builder-backend')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess illa-builder-backend-ws]${NC}"
    echo "$(_check_process 'illa-builder-backend-ws')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess illa-supervisor-backend]${NC}"
    echo "$(_check_process 'illa-supervisor-backend')"
    echo 

    echo -e "${LIGHTBLUE}┌[checking porcess illa-supervisor-backend-internal]${NC}"
    echo "$(_check_process 'illa-supervisor-backend-internal')"
    echo 


    echo 
    echo -e "${LIGHTBLUE}[checkout post init status] done.${NC}"
    echo 

}




if ! _is_sourced; then
	_main "$@"
fi
