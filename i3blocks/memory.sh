#!/bin/bash
memory=$(free -m | awk 'NR==2{printf "%s/%s MB (%.2f%%)\n", $3,$2,$3*100/$2 }')
swap=$(free -m | awk 'NR==3{printf "%s/%s MB (%.2f%%)\n", $3,$2,$3*100/$2 }')
memory_percent=$(echo "$memory" | awk '{printf $3}' | tr -d '(%)')
swap_percent=$(echo "$swap" | awk '{printf $3}' | tr -d '(%)')
# First echo updates the full_text i3bar key
echo "$memory - SWAP $swap"
# Second echo updates the short_text i3bar key
echo "$memory - SWAP $swap"
# Third echo updates the color i3bar key
if [ $(echo "$swap_percent>0"| bc) -eq 1 ] || [ $(echo "$memory_percent>=90"| bc) -eq 1 ]
then
    echo "#af3a03"
elif [ $(echo "$memory_percent>=70"| bc) -eq 1 ] && [ $(echo "$memory_percent<90"| bc) -eq 1 ]
then
    echo "#b57614"
fi

