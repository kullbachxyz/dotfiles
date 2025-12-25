#!/bin/bash

# Default step size
STEP="5%"

# Function to get the correct control name
get_control_name() {
  # First check for 'Master', then fallback to 'PCM'
  if amixer scontrols | grep -q "Master"; then
    echo "Master"
  elif amixer scontrols | grep -q "PCM"; then
    echo "PCM"
  else
    echo "No suitable control found"
    exit 1
  fi
}

# Get current volume
get_volume() {
  CONTROL=$(get_control_name)
  amixer get "$CONTROL" | grep -oP '\[\K[0-9]+(?=%\])' | head -1
}

# Check if muted
is_muted() {
  CONTROL=$(get_control_name)
  amixer get "$CONTROL" | grep -q '\[off\]'
}

# Main logic based on input argument
case "$1" in
  up)
    CONTROL=$(get_control_name)
    amixer set "$CONTROL" "$STEP"+ unmute > /dev/null
    ;;
  down)
    CONTROL=$(get_control_name)
    amixer set "$CONTROL" "$STEP"- unmute > /dev/null
    ;;
  mute)
    CONTROL=$(get_control_name)
    amixer set "$CONTROL" toggle > /dev/null
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

