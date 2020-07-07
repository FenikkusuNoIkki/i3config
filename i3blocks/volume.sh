#!/bin/bash
vol=$(amixer get Master | awk '/Mono.+/ {print $6=="[off]"?$6:$4}' | tr -d '[]%')
if [ $vol = "off" ]
then
    echo "婢"
elif [ $vol -lt 40 ]
then
    echo "奄 $vol"
elif [ $vol -ge 40 ] && [ $vol -lt 70 ]
then
    echo "奔 $vol"
else
    echo "墳 $vol"
fi


