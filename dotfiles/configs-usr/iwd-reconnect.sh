#!/bin/bash
while true; do 
    if ! ip route>/dev/null; then
        systemctl restart iw
        sleep 5
    else
        sleep 5
    fi
done

