#!/bin/bash
echo $(curl -s wttr.in/"$(curl --silent ipinfo.io/loc)"\?format\=3)
