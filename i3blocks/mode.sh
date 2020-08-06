#!/bin/bash
mode=$(ls -l ~/.config/i3/i3blocks_top.conf | awk '$0 ~ "laptop"{print $1}')
# First echo updates the full_text i3bar key
if [ -z $mode ]
then
    echo "[desktop]"
else
    echo "[laptop]"
fi
