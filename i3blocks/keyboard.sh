#!/bin/bash
keyboard_language=$(setxkbmap -query | awk ' /layout/ {print $2}')
# First echo updates the full_text i3bar key
echo "$keyboard_language"
