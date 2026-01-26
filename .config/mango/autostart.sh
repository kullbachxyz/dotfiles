# Session defaults
export TERMINAL=foot
export EDITOR=nvim
export BROWSER=librewolf

# Wayland app preferences
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland

# Desktop/session hints
export XDG_CURRENT_DESKTOP=wayland
export XDG_SESSION_TYPE=wayland

# Theme preferences
export GTK_THEME=Adwaita-dark
export QT_QPA_PLATFORMTHEME=qt6ct

# UI services
bg_color="$(awk '/@define-color[[:space:]]+wb-bg/ {gsub(/;/,"",$3); print $3; exit}' ~/.config/colors/current.css)"
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
swaybg -c "${bg_color:-#1a1b26}" &
#wlsunset -l 50.9375 -L 6.9603 -T 6500 -t 3300
mako &
