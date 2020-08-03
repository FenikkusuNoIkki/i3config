#!/bin/bash
# First echo updates the full_text i3bar key
echo $(xbacklight -get | cut -d'.' -f 1)
