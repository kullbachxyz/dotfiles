waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
swaybg -c 282828 &
#wlsunset -l 50.9375 -L 6.9603 -T 6500 -t 3300
mako &

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" &
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" &
export QT_QPA_PLATFORMTHEME=qt6ct &
