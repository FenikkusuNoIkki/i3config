#!/bin/bash
keyboard_language=$(setxkbmap -query | awk ' /layout/ {print $2}')
if [ $keyboard_language == "fr" ] || [ $keyboard_language == "fr-latin9" ]
then
    setxkbmap us
else
    setxkbmap fr-latin9
fi
