waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &
#swaybg -i ~/walls/wall >/dev/null 2>&1 &
swaybg -c 282828 >/dev/null 2>&1 &
#wlsunset -l 50.9375 -L 6.9603 -T 6500 -t 3300 >/dev/null 2>&1 &
mako >/dev/null 2>&1 &

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
export QT_QPA_PLATFORMTHEME=qt6ct
