#!/usr/bin/env bash
set -euo pipefail

# Low battery notifier using upower + notify-send.
# Thresholds are percentages.
WARN_LEVEL=30
CRIT_LEVEL=15
POLL_SECS=60
COOLDOWN_SECS=300

last_notify_ts=0

get_battery_device() {
  upower -e | grep -m1 '/battery_' || true
}

get_percentage() {
  local dev="$1"
  upower -i "$dev" | grep 'percentage' | awk '{print $2}' | tr -d '%'
}

get_state() {
  local dev="$1"
  upower -i "$dev" | grep '^ *state:' | awk '{print $2}'
}

main() {
  local dev
  dev="$(get_battery_device)"
  if [[ -z "$dev" ]]; then
    exit 0
  fi

  if [[ "${1:-}" == "--once" ]]; then
    local pct state
    pct="$(get_percentage "$dev")"
    state="$(get_state "$dev")"
    echo "Battery: ${pct}% (${state})"
    exit 0
  fi

  while true; do
    local pct state now
    pct="$(get_percentage "$dev")"
    state="$(get_state "$dev")"
    now="$(date +%s)"

    if [[ "$state" == "discharging" ]]; then
      if (( pct <= CRIT_LEVEL )); then
        if (( now - last_notify_ts >= COOLDOWN_SECS )); then
          notify-send -u critical "Battery critical" "${pct}% remaining"
          last_notify_ts="$now"
        fi
      elif (( pct <= WARN_LEVEL )); then
        if (( now - last_notify_ts >= COOLDOWN_SECS )); then
          notify-send -u normal "Battery low" "${pct}% remaining"
          last_notify_ts="$now"
        fi
      fi
    fi

    sleep "$POLL_SECS"
  done
}

main "$@"
