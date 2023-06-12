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


_checkout_runtime_env() {
    local uname_info; uname_info=`uname -a`
    local glibc_version; glibc_version=`ldd --version| grep 'ldd'`
     # output
    echo 'kernel version: '${uname_info}
    echo 'glibc version: '${glibc_version}
}

_is_user_exists() {
    if id "$1" &>/dev/null; then
        echo \"$1\"' found'
    else
        echo \"$1\"' NOT found'
    fi
}

_checkout_now_user() {
    local idinfo; idinfo=`id`
    echo \"$idinfo\"
}


_grant_permission_to_now_user() {
    local current_user; current_user="$(id -u)"
    local current_user_name; current_user_name="$(id -un)"
    local current_group; current_group="$(id -g)"

    
}
    
_checkout_gosu() {
    local gosu_versoin; gosu_versoin=`/usr/local/bin/gosu --version`
    echo "gosu info: \"$gosu_version\""
}

_main() {

    echo 
    echo -e "${LIGHTBLUE}[checkout runtime environment]${NC}"
    echo 

    # check kernel and lib version
    _checkout_runtime_env    

    # check out gosu info
    _checkout_gosu
   
    # check user id
    echo "detect user:" $(_is_user_exists 'root')
    echo "detect user:" $(_is_user_exists 'postgres') 
    echo "current user is:" $(_checkout_now_user) 


    # grant permission
    _grant_permission_to_now_user
    


    echo 
    echo -e "${LIGHTBLUE}[checkout runtime environment] done.${NC}"
    echo 

}






if ! _is_sourced; then
	_main "$@"
fi
