#!/bin/bash
CWD=$(pwd)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE='/var/bashnet/application.log'

touch $LOG_FILE

HANDLERS='-e "s/.*/file_handler &/"'

for f in $DIR/handlers/*; do source $f; done

function main {
    while true; do
        coproc incoming_request
        nc -l -p 8080 <&"${COPROC[0]}" >&"${COPROC[1]}"
    done
}

function incoming_request {
    local IN
    local METHOD
    local URL
    local VERSION

    read METHOD URL VERSION

    log_info "Incomming request method=$METHOD path=$URL version=$VERSION"

    local HEADERS=$(read_headers)
    local HANDLER=$(eval "sed $HANDLERS <<< '$URL'")

    if [[ -n "$HANDLER" ]]; then
        $HANDLER "$METHOD" "$URL" "$HEADERS"
    else
        error_handler 500 "No handler found"
    fi
}

function read_headers {
    while read -r IN; do
        IN=$(echo $IN | tr -d '\r' | tr -d '\n')
        if [ -z "$IN" ]; then
            log_info "End of headers"
            break
        else
            log_debug "$IN"
            echo "$IN"
        fi
    done
}

function log_info {
    echo "INFO: $1" >> $LOG_FILE
}

function log_debug {
    echo "DEBUG: $1" >> $LOG_FILE
}

function log_error {
    echo "ERROR: $1" >> $LOG_FILE
}

main
