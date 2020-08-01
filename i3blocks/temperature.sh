#!/bin/bash
temp=$(sensors | grep -F 'Core' | awk '{print $3}' | tr -s '\n' ' ' | sed 's/+//g')
# First echo updates the full_text i3bar key
echo "$temp"
# Second echo updates the short_text i3bar key
echo "$temp"
# Third echo updates the color i3bar key
for test in $temp
do
    core_temp="${test//[^0-9.]/}"
    if [ $(echo "$core_temp>=60"| bc) -eq 1 ] && [ $(echo "$core_temp<90"| bc) -eq 1 ]
    then
	echo "#b57614"
	break
    elif [ $(echo "$core_temp>=90"| bc) -eq 1 ] 
    then
	echo "#af3a03"
    fi
done
