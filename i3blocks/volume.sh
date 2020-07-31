#!/bin/bash
vol=$(amixer get Master | awk '/Mono.+/ {print $6=="[off]"?$6:$4}' | tr -d '[]%')
if [ -z "$vol" ]
then
    vol=$(amixer get Master | awk '/Left/ {print $6=="[off]"?$6:$5}' | tr -d '[]%')
fi
# First echo updates the full_text i3bar key
echo "$vol"
