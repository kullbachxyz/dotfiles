#!/bin/bash

# Default step size
STEP="10%"

# Function to get current brightness percentage
get_brightness() {
  brightnessctl -m | awk -F, '{print $4}' | tr -d '%'
}

case "$1" in
  up)
    brightnessctl set +$STEP
    ;;
  down)
    brightnessctl set $STEP-
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
