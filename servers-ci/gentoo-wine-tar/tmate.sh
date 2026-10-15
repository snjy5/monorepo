#!/bin/dash
sudo apt update
sudo apt install -y tmate tmux
tmate -S /tmp/tmate.sock new-session -d
tmate -S /tmp/tmate.sock wait tmate-ready
tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' > /tmp/new 2>&1

timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'
timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'
timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'
timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'
timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'
timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'
timeout 50m dash -c 'while true; do sleep 3 && cat /tmp/new 2>&1; done'

