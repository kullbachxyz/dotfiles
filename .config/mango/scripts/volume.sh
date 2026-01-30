#!/bin/bash

# Default step size
STEP="5%"

# Pick a backend: prefer wpctl if available (PipeWire), else amixer (ALSA)
BACKEND=""
if command -v wpctl >/dev/null 2>&1; then
  BACKEND="wpctl"
elif command -v amixer >/dev/null 2>&1; then
  BACKEND="amixer"
fi

if [ -z "$BACKEND" ]; then
  echo "No audio backend found (wpctl or amixer required)." >&2
  exit 1
fi

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
  if [ "$BACKEND" = "wpctl" ]; then
    # wpctl prints a float 0.00..1.00
    wpctl get-volume @DEFAULT_AUDIO_SINK@ \
      | awk '{v=$2*100; printf "%d\n", v+0.5}'
  else
    CONTROL=$(get_control_name)
    amixer get "$CONTROL" | grep -oP '\[\K[0-9]+(?=%\])' | head -1
  fi
}

# Check if muted
is_muted() {
  if [ "$BACKEND" = "wpctl" ]; then
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q '\[MUTED\]'
  else
    CONTROL=$(get_control_name)
    amixer get "$CONTROL" | grep -q '\[off\]'
  fi
}

# Send a desktop notification if available
notify() {
  if command -v notify-send >/dev/null 2>&1; then
    # Clear existing notifications (mako) to avoid stacking
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
      notify-send -u low -t 1200 "Volume" "${bar}"
    else
      notify-send -u low -t 1200 "Volume" "$1"
    fi
  fi
}

# Main logic based on input argument
case "$1" in
  up)
    if [ "$BACKEND" = "wpctl" ]; then
      wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
      wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}+" --limit 1.0
    else
      CONTROL=$(get_control_name)
      amixer set "$CONTROL" "$STEP"+ unmute > /dev/null
    fi
    notify "$(get_volume)"
    ;;
  down)
    if [ "$BACKEND" = "wpctl" ]; then
      wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
      wpctl set-volume @DEFAULT_AUDIO_SINK@ "${STEP}-"
    else
      CONTROL=$(get_control_name)
      amixer set "$CONTROL" "$STEP"- unmute > /dev/null
    fi
    notify "$(get_volume)"
    ;;
  mute)
    if [ "$BACKEND" = "wpctl" ]; then
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    else
      CONTROL=$(get_control_name)
      amixer set "$CONTROL" toggle > /dev/null
    fi
    if is_muted; then
      notify "Muted"
    else
      notify "$(get_volume)"
    fi
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
