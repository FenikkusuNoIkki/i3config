#!/bin/bash
memory=$(free -m | awk 'NR==2{printf "%s/%s MB (%.2f%%)\n", $3,$2,$3*100/$2 }')
swap=$(free -m | awk 'NR==3{printf "%s/%s MB (%.2f%%)\n", $3,$2,$3*100/$2 }')
memory_percent=$(free -m | awk 'NR==2{printf "%.2f\n", $3*100/$2 }')
swap_percent=$(free -m | awk 'NR==3{printf "%.2f\n", $3*100/$2 }')
# First echo updates the full_text i3bar key
echo "$memory - SWAP $swap"
# Second echo updates the short_text i3bar key
echo "$memory - $swap"
if [ $(echo "$swap_percent>0"| bc) -eq 1 ] || [ $(echo "$memory_percent>=90"| bc) -eq 1 ]
then
    # Third echo updates the color i3bar key
    echo "#af3a03"
elif [ $(echo "$memory_percent>=70"| bc) -eq 1 ] && [ $(echo "$memory_percent<90"| bc) -eq 1 ]
then
    # Third echo updates the color i3bar key
    echo "#b57614"
fi

