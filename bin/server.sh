#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function main {
    if type tcpserver > /dev/null 2>&1; then
        tcpserver 0 8080 sh -c $DIR/incoming_request.sh
    else
        while true; do
            coproc exec_incoming_request
            nc -l -p 8080 <&"${COPROC[0]}" >&"${COPROC[1]}"
            wait $!
        done
    fi
}

function exec_incoming_request {
    $DIR/incoming_request.sh
}

main
