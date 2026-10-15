#!/bin/bash

# Delay after AC power loss in seconds
DELAY=28800

# Schedule the wake-up event
rtcwake -m off -s ${DELAY}
