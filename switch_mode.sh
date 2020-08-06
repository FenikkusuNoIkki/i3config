#!/bin/bash
mode=$(ls -l ~/.config/i3/i3blocks_top.conf | awk '$0 ~ "laptop"{print $1}')
if [ -z $mode ]
then
    # Change from desktop to laptop mode
    ln -sf ~/.config/i3/i3blocks_top_laptop.conf ~/.config/i3/i3blocks_top.conf
    ln -sf ~/.config/i3/i3blocks_bottom_laptop.conf ~/.config/i3/i3blocks_bottom.conf
else
    # Change from laptop to desktop mode
    ln -sf ~/.config/i3/i3blocks_top_desktop.conf ~/.config/i3/i3blocks_top.conf
    ln -sf ~/.config/i3/i3blocks_bottom_desktop.conf ~/.config/i3/i3blocks_bottom.conf
fi
i3-msg restart
