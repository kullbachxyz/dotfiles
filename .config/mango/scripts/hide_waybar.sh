#!/usr/bin/bash

startd=$(pgrep waybar)

if [ -n "$startd" ]; then
	pkill waybar
else 
  waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &
fi
