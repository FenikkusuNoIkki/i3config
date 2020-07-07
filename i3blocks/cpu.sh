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

# Keep this as last for our next read 
cpu_last=("${cpu_now[@]}") 
cpu_last_sum=$cpu_sum 

# First echo updates the full_text i3bar key
echo "$cpu_usage%" 
# Second echo updates the short_text i3bar key
echo "$cpu_usage%" 
# Third echo updates the color i3bar key
echo "#b16286" 
