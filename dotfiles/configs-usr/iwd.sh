#!/bin/bash

while sleep 2; do
    if test -z "$(ip route)"; then
        iwctl station wlan0 connect moto || sleep 2
    fi
done
