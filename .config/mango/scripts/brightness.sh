#!/bin/bash

# Default step size
STEP="10%"

# Function to get current brightness percentage
get_brightness() {
  brightnessctl -m | awk -F, '{print $4}' | tr -d '%'
}

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    if command -v makoctl >/dev/null 2>&1; then
      makoctl dismiss -a >/dev/null 2>&1
    fi
    if echo "$1" | grep -qE '^[0-9]+$'; then
      local p="$1"
      local total=22
      local filled=$(( (p * total + 50) / 100 ))
      local bar=""
      for ((i=1; i<=total; i++)); do
        if [ "$i" -le "$filled" ]; then
          bar="${bar}█"
        else
          bar="${bar}░"
        fi
      done
      notify-send -u low -t 1200 "Brightness" "${bar}"
    else
      notify-send -u low -t 1200 "Brightness" "$1"
    fi
  fi
}

case "$1" in
  up)
    brightnessctl set +$STEP
    notify "$(get_brightness)"
    ;;
  down)
    brightnessctl set $STEP-
    notify "$(get_brightness)"
    ;;
  get)
    get_brightness
    exit 0
    ;;
  *)
    echo "Usage: $0 {up|down|get}"
    exit 1
    ;;
esac
