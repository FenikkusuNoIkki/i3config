#!/bin/bash 
# Get the first line with aggregate of all CPUs 
cpu_now=($(head -n1 /proc/stat)) 
# Get all columns but skip the first (which is the "cpu" string) 
cpu_sum="${cpu_now[@]:1}" 
# Replace the column seperator (space) with + 
cpu_sum=$((${cpu_sum// /+})) 
# Get the idle% 
cpu_idle=$((cpu_now[4]))
# Calc percentage 
cpu_usage=$((100-(100 * cpu_idle / cpu_sum)))

# First echo updates the full_text i3bar key
echo "$cpu_usage%" 
# Second echo updates the short_text i3bar key
echo "$cpu_usage%" 
# Third echo updates the color i3bar key
if [ $cpu_usage -gt 50 ] && [ $cpu_usage -lt 80 ]
then
    echo "#b57614" 
elif [ $cpu_usage -gt 80 ] 
then
    echo "#af3a03" 
fi
