#!/bin/bash

# Default step size
STEP="5%"

get_volume() {
  amixer get Master | grep -oP '\[\K[0-9]+(?=%\])' | head -1
}

is_muted() {
  amixer get Master | grep -q '\[off\]'
}

case "$1" in
  up)
    amixer set Master "$STEP"+ unmute > /dev/null
    ;;
  down)
    amixer set Master "$STEP"- unmute > /dev/null
    ;;
  mute)
    amixer set Master toggle > /dev/null
    ;;
  get)
    if is_muted; then
      echo "0"
    else
      get_volume
    fi
    exit 0
    ;;
  *)
    echo "Usage: $0 {up|down|mute|get}"
    exit 1
    ;;
esac
