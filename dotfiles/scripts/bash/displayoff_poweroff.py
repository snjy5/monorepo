#!/usr/bin/env python3
import os, sys, time

time_to_sleep = 3 * 60 * 60 # 3 hours in seconds
start_time = 0

def main():
    global start_time
    if os.path.exists('/tmp/lock'):
        start_time = 0
        return
    
    if os.system('lsof /dev/snd/pcmC0D0p | grep -qP "\S"')  == 0:
        start_time = 0
        return

    if os.system('pgrep -x apt > /dev/null 2>&1')  == 0:
        start_time = 0
        return

    if os.system('DISPLAY=:0 xset q | grep -q "Monitor is Off"') == 0:
        if start_time == 0:
            start_time = time.time()

        elapsed_time = int(time.time() - start_time)
        
        if elapsed_time >= time_to_sleep:
            print(f"Monitor off for {(elapsed_time)//60} minutes")
            os.system('/sbin/poweroff')
    else:
        start_time = 0
        return

try:
    while True:
        main()
        time.sleep(10)
except (SystemExit,KeyboardInterrupt) as e:
    print(e)
    sys.exit(0)
