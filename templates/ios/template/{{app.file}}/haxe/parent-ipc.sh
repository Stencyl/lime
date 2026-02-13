#!/bin/sh

# Expect these env vars optionally:
#   PARENT_REQ_FIFO
#   PARENT_RESP_FIFO

if [ -n "$PARENT_REQ_FIFO" ] && \
   [ -n "$PARENT_RESP_FIFO" ]; then

    # Send request in the form of the build environment,
    # which the parent will then pass to the "make" command
    {
        printf "%s\0" "___CWD___=$(pwd)"
        env -0
    } > "$PARENT_REQ_FIFO"

    # Wait for parent to be finished building
    read response < "$PARENT_RESP_FIFO"

    if [ "$response" != "DONE" ]; then
        echo "Unexpected response: $response"
        exit 1
    fi
else
    make
fi