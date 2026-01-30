#!/usr/bin/env bash
set -euo pipefail

# Icons from Nerd Fonts, text labels are what rofi shows
entries="\
  Lock
  Logout
⏾  Suspend
  Hibernate
  Reboot
  Shutdown"

choice="$(printf '%s\n' "$entries" | rofi -dmenu -i -p "Power" \
  -theme ~/.config/rofi/power-wal.rasi \
  -theme-str 'window { background-color: #000000d9; }')"

case "$choice" in
  "  Lock")
    bash ~/.config/mango/scripts/lock.sh
    ;;
  "  Logout")
    # same as your wlogout layout
    mmsg -q
    ;;
  "⏾  Suspend")
    systemctl suspend
    ;;
  "  Hibernate")
    systemctl hibernate
    ;;
  "  Reboot")
    systemctl reboot
    ;;
  "  Shutdown")
    systemctl poweroff
    ;;
  *)
    # pressed Escape or closed rofi
    exit 0
    ;;
esac
