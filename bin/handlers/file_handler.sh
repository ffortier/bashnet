#!/bin/bash

DEFAULT_DOCUMENT='index.html'

function file_handler {
    local URL="$(sed -e 's/\/$//' -e 's/^\///' <<< $1)"

    if [[ -d "$CWD/$URL" ]]; then
        URL="$URL/$DEFAULT_DOCUMENT"
    fi

    log_debug "URL=$URL"

    if [[ -f "$CWD/$URL" ]]; then
        file_handler_send_file "$CWD/$URL"
    else
        error_handler 404 'Not found'
    fi
}

function file_handler_send_file {
    local FILE_NAME="$1"
    local CONTENT_LENGTH=$(stat -c %s "$FILE_NAME")
    local CONTENT_TYPE=$(file_handler_get_content_type "$FILE_NAME")

    echo -e "HTTP/1.1 200 OK\r
Content-Type: $CONTENT_TYPE\r
Content-Length: $CONTENT_LENGTH\r
Connection: close\r
\r"
    cat $FILE_NAME
}

function file_handler_get_content_type {
    echo "text/html"
}