#!/usr/bin/env bash
set -Eeo pipefail

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}


_main() {

    echo 
    echo 'config init.'
    echo 

    echo 
    echo 'dumping config:'
    echo '    ILLA_HOME_DIR: '$ILLA_HOME_DIR''
    echo '    PG_VOLUMN: '$PG_VOLUMN''
    echo '    API_SERVER_ADDRESS: '$API_SERVER_ADDRESS''
    echo '    API_SERVER_PORT: '$API_SERVER_PORT''
    echo '    WEBSOCKET_SERVER_ADDRESS: '$WEBSOCKET_SERVER_ADDRESS''
    echo '    WEBSOCKER_PORT: '$WEBSOCKER_PORT''
    echo '    WSS_ENABLED: '$WSS_ENABLED''
    echo 

    # replace frontend repo
    if [ ! -n "$API_SERVER_PORT" ]; then
        echo "API_SERVER_PORT not defined, skip."
    else
        echo 'config API_SERVER_PORT to:'$API_SERVER_PORT''
        sed -i "s/localhost/localhost:$API_SERVER_PORT/g" /opt/illa/illa-frontend/assets/*.js
    fi

    if [ ! -n "$API_SERVER_ADDRESS" ]; then
        echo "API_SERVER_ADDRESS not defined, skip."
    else
        echo 'config API_SERVER_ADDRESS to:'$API_SERVER_ADDRESS''
        sed -i "s/localhost/$API_SERVER_ADDRESS/g" /opt/illa/illa-frontend/assets/*.js
    fi

    if [ ! -n "$RELEASE_VERSION" ]; then
        echo "RELEASE_VERSION not defined, skip."
    else
        sed -i "s#<head>#<head><meta release-version=\"$RELEASE_VERSION\" />#g" /opt/illa/illa-frontend/index.html
    fi
    

    echo 
    echo 'config init done.'
    echo 

}






if ! _is_sourced; then
	_main "$@"
fi
