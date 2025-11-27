!/usr/bin/env bash
set -euo pipefail

notify() {
  local msg="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "wal-wayland" "$msg"
  else
    printf 'wal-wayland: %s\n' "$msg" >&2
  fi
}

if [ $# -lt 1 ]; then
  notify "No file given. Usage: wal-wayland.sh /path/to/image"
  exit 1
fi

src="$1"

if [ ! -f "$src" ]; then
  notify "File does not exist: $src"
  exit 1
fi

# --- copy to canonical wallpaper path ---
walls_dir="$HOME/walls"
mkdir -p "$walls_dir"
cp -f -- "$src" "$walls_dir/wall"
wall="$walls_dir/wall"

# --- set wallpaper with swaybg ---
if command -v swaybg >/dev/null 2>&1; then
  pkill -x swaybg >/dev/null 2>&1 || true
  swaybg -i "$wall" >/dev/null 2>&1 &
else
  notify "swaybg not found; wallpaper not set"
fi

# --- run pywal (force fresh scheme, ignore cache) ---
if ! command -v wal >/dev/null 2>&1; then
  notify "wal command not found. Install python-pywal."
  exit 1
fi

wal -c >/dev/null 2>&1 || true
wal -i "$wall" -q

cache="$HOME/.cache/wal"
colors_sh="$cache/colors.sh"

if [ ! -f "$colors_sh" ]; then
  notify "colors.sh not found; pywal did not generate theme"
  exit 1
fi

# load pywal colors: background, foreground, color0..15
# shellcheck source=/dev/null
set +u
. "$colors_sh"
set -u


# --- safe fallbacks (only if unset/empty) ---
bg="${background:-#000000}"
fg="${foreground:-#ffffff}"

c0="${color0:-$bg}"
c1="${color1:-$fg}"
c2="${color2:-$fg}"
c3="${color3:-$fg}"
c4="${color4:-$fg}"
c5="${color5:-$fg}"
c6="${color6:-$fg}"
c7="${color7:-$fg}"
c8="${color8:-$fg}"
c9="${color9:-$fg}"
c10="${color10:-$fg}"
c11="${color11:-$fg}"
c12="${color12:-$fg}"
c13="${color13:-$fg}"
c14="${color14:-$fg}"
c15="${color15:-$fg}"

strip_hash() { printf '%s\n' "${1#\#}"; }

hex_to_rgb() {
  # accepts "#RRGGBB" or "RRGGBB" and prints "R, G, B"
  local hex="${1#\#}"
  local r="${hex:0:2}"
  local g="${hex:2:2}"
  local b="${hex:4:2}"
  printf '%d, %d, %d' "0x$r" "0x$g" "0x$b"
}

to_mango_color() {
  local hex="${1#\#}"
  printf '0x%sff\n' "$hex"
}

########################################################################
# MANGOWC – border + focus colors
########################################################################

mango_conf="$HOME/.config/mango/config.conf"

if [ -f "$mango_conf" ]; then
  border_hex="$bg"   # or $c0 if you prefer
  focus_hex="$c4"    # or $c8 / whatever you like

  border_col="$(to_mango_color "$border_hex")"
  focus_col="$(to_mango_color "$focus_hex")"

  sed -i \
    -e "s/^bordercolor=.*/bordercolor=$border_col/" \
    -e "s/^focuscolor=.*/focuscolor=$focus_col/" \
    "$mango_conf"
fi


########################################################################
# FOOT (terminal) – cursor = double color of regular7
########################################################################

foot_theme="$cache/colors-foot.ini"

cat > "$foot_theme" <<EOF
[colors]
cursor=$(strip_hash "$c7") $(strip_hash "$c7")
background=$(strip_hash "$bg")
foreground=$(strip_hash "$fg")

regular0=$(strip_hash "$c0")
regular1=$(strip_hash "$c1")
regular2=$(strip_hash "$c2")
regular3=$(strip_hash "$c3")
regular4=$(strip_hash "$c4")
regular5=$(strip_hash "$c5")
regular6=$(strip_hash "$c6")
regular7=$(strip_hash "$c7")

bright0=$(strip_hash "$c8")
bright1=$(strip_hash "$c9")
bright2=$(strip_hash "$c10")
bright3=$(strip_hash "$c11")
bright4=$(strip_hash "$c12")
bright5=$(strip_hash "$c13")
bright6=$(strip_hash "$c14")
bright7=$(strip_hash "$c15")
EOF

########################################################################
# WAYBAR – CSS colors file
########################################################################

waybar_colors="$cache/colors-waybar.css"

cat > "$waybar_colors" <<EOF
@define-color wb-bg $bg;
@define-color wb-fg $fg;
@define-color wb-accent $c4;
@define-color wb-accent-alt $c5;
@define-color wb-warning $c3;
@define-color wb-error $c1;
EOF

########################################################################
# ROFI – minimal .rasi color theme
########################################################################

rofi_colors="$cache/colors-rofi.rasi"

cat > "$rofi_colors" <<EOF
* {
  background: $bg;
  background-alt: $c0;
  foreground: $fg;
  selected: $c4;
  border-color: $c4;
  separatorcolor: $c4;
  urgent: $c1;
}
EOF

########################################################################
# MAKO – notification colors
########################################################################

mako_colors="$cache/colors-mako"

cat > "$mako_colors" <<EOF
background-color=$bg
text-color=$fg
border-color=$c4
EOF

########################################################################
# CHROMIUM – theme manifest based on wal colors
########################################################################

chrome_theme_dir="$HOME/wal-chrome-theme"
mkdir -p "$chrome_theme_dir"

bg_rgb="$(hex_to_rgb "$bg")"
fg_rgb="$(hex_to_rgb "$fg")"
accent_rgb="$(hex_to_rgb "$c4")"

cat > "$chrome_theme_dir/manifest.json" <<EOF
{
  "manifest_version": 3,
  "name": "Wal Flat Theme",
  "version": "1.0",
  "description": "Flat Chromium theme generated by wal-wayland.sh",
  "theme": {
    "colors": {
      "frame": [ $bg_rgb ],
      "toolbar": [ $bg_rgb ],
      "tab_background_text": [ $fg_rgb ],
      "tab_text": [ $fg_rgb ],
      "bookmark_text": [ $fg_rgb ],
      "toolbar_button_icon": [ $fg_rgb ],
      "ntp_background": [ $bg_rgb ],
      "ntp_text": [ $fg_rgb ],
      "ntp_link": [ $accent_rgb ],
      "button_background": [ $accent_rgb ]
    }
  }
}
EOF

########################################################################
# FIREFOX – update theme via pywalfox (if available)
########################################################################

if command -v pywalfox >/dev/null 2>&1; then
  pywalfox update >/dev/null 2>&1 || true
fi

########################################################################
# reload Waybar, pywalfox and mako so new colors apply immediately
########################################################################

if command -v pywalfox >/dev/null 2>&1; then
  pywalfox update >/dev/null 2>&1 || true
fi

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -USR2 waybar || true
fi

makoctl reload

mmsg -d reload_config

notify "Wallpaper + colors updated from $(basename "$src")"

