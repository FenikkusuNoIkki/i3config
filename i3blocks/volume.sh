#!/bin/bash
vol=$(amixer get Master | awk '/Mono.+/ {print $6=="[off]"?$6:$4}' | tr -d '[]%')
# First echo updates the full_text i3bar key
echo "$vol"
# Second echo updates the short_text i3bar key
echo "$vol"
# Third echo updates the color i3bar key
if [ $vol -gt 80 ] && [ $vol -lt 90 ]
then
    echo "#af3a03" 
elif [ $vol -gt 90 ]
then
    echo "#9d0006" 
fi


