#!/bin/bash

function error_handler {
    local ERROR_CODE=$1
    local ERROR_MESSAGE="$2"

    echo -n -e "HTTP/1.1 $ERROR_CODE OK\r
Content-Type: text/plain\r
Content-Length: ${#ERROR_MESSAGE}\r
Connection: close\r
\r
$ERROR_MESSAGE"
}