#!/usr/bin/env python
import subprocess
subprocess = subprocess.Popen("amixer -D pulse get Master | awk -F 'Left:|[][]' 'BEGIN{RS=\"\"}{print $5==\"off\"?$5:$3 }' | tr -d '%'", shell=True, stdout=subprocess.PIPE)
volume = subprocess.stdout.read()
str_data = volume.decode('utf-8')
vol = str_data.splitlines()
if vol[0] == "off":
    print("婢")
vol_int = int(vol[0])
if vol_int < 40:
    print("奄 %s%%" % vol_int)
elif vol_int >= 40 and vol_int < 70:
    print("奔 %s%%" % vol_int)
elif vol_int >= 70:
    print("墳 %s%%" % vol_int)


