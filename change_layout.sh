#!/bin/bash
keyboard_language=$(setxkbmap -query | awk ' /layout/ {print $2}')
if [ $keyboard_language == "fr" ] || [ $keyboard_language == "fr-latin9" ]
then
    setxkbmap us
    ln -sf ~/.config/i3/config_en ~/.config/i3/config
else
    setxkbmap fr-latin9
    ln -sf ~/.config/i3/config_fr ~/.config/i3/config
fi
