#!/bin/bash
hdd_state=0
for partition in "$@"
do
    infos=$(df -h $partition --output=size,used,pcent | awk 'NR==2{printf "%s/%s (%s)\n", $2,$1,$3 }')
    hdd_percent=$(echo "$infos" | awk '{print $2}' | tr -d '(%)')
    if [ $hdd_percent -ge 70 ] && [ $hdd_percent -lt 90 ]
    then
	hdd_state=1
    elif [ $hdd_percent -ge 90 ] 
    then
	hdd_state=2
    fi
    output="$output [$partition] $infos"
done
# First echo updates the full_text i3bar key
echo "$output"
# Second echo updates the short_text i3bar key
echo "$output"
# Third echo updates the color i3bar key
if [ $hdd_state -eq 1 ]
then
    echo "#b57614"
elif [ $hdd_state -eq 2 ]
then
    echo "#af3a03"
fi
