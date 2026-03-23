#!/bin/sh

# Start keyring for secrets/pkcs11 (ssh dropped in gnome-keyring 46+)
eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)"
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

# Bootstrap keyring for Electron apps (Element, etc.)
secret-tool store --label='xinitrc bootstrap' xinitrc bootstrap <<< "bootstrap" 2>/dev/null

remaps &
mpd &
dunst &
picom &
xwallpaper --zoom "$HOME/.local/share/walls/wall" &

# Export GUI env to user systemd/DBus so keybinding-launched apps see it.
systemctl --user import-environment DISPLAY XAUTHORITY XDG_RUNTIME_DIR SSH_AUTH_SOCK
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_RUNTIME_DIR SSH_AUTH_SOCK

pipewire &
sleep 1
pipewire-pulse &
wireplumber &

xset s 600 &
xss-lock -- slock &
dwmblocks &
exec dbus-launch dwm
