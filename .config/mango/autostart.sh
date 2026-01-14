# Session defaults
export TERMINAL=alacritty
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

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Ensure agent running (systemd user agent)
systemctl --user start ssh-agent >/dev/null 2>&1

# Add key once per session via GUI askpass (no TTY in autostart)
# Requires an askpass helper like openssh-askpass or ksshaskpass.
if [ -r ~/.ssh/id_ed25519 ]; then
    askpass_bin="$(command -v ssh-askpass 2>/dev/null || true)"
    if [ -n "${askpass_bin}" ]; then
        SSH_ASKPASS_REQUIRE=force SSH_ASKPASS="${askpass_bin}" ssh-add ~/.ssh/id_ed25519 </dev/null 2>&1
    fi
fi

# Theme preferences
export GTK_THEME=Adwaita-dark
export QT_QPA_PLATFORMTHEME=qt6ct

# UI services
bg_color="$(awk '/@define-color[[:space:]]+wb-bg/ {gsub(/;/,"",$3); print $3; exit}' ~/.config/colors/current.css)"
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
swaybg -c "${bg_color:-#1a1b26}" &
#wlsunset -l 50.9375 -L 6.9603 -T 6500 -t 3300
mako &
