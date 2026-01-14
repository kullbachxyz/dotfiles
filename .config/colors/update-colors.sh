#!/usr/bin/env bash
set -euo pipefail

colors_dir="${COLORS_DIR:-$HOME/.config/colors}"
waybar_style="${WAYBAR_STYLE:-$HOME/.config/waybar/style.css}"
rofi_colors="${ROFI_COLORS:-$HOME/.config/rofi/colors-from-css.rasi}"
librewolf_profile="${LIBREWOLF_PROFILE:-$HOME/.librewolf/xkvsxbr3.default-default}"
mako_colors="${MAKO_COLORS:-$HOME/.config/mako/colors}"
current_css="$colors_dir/current.css"
out_file="${ALACRITTY_COLORS:-$colors_dir/alacritty-colors.toml}"

select_theme() {
  local theme_file="${1:-}"
  local selected=""

  if [[ -n "$theme_file" ]]; then
    if [[ "$theme_file" = /* ]]; then
      selected="$theme_file"
    else
      selected="$colors_dir/$theme_file"
    fi
  else
    if ! command -v rofi >/dev/null 2>&1; then
      echo "rofi not found; pass a theme filename instead." >&2
      ls -1 "$colors_dir"/*.css 2>/dev/null | xargs -n1 basename >&2
      exit 1
    fi
    selected="$(ls -1 "$colors_dir"/*.css 2>/dev/null | xargs -n1 basename | grep -v '^current\.css$' | sort | rofi -dmenu -i -p "Theme")"
    [[ -n "$selected" ]] || exit 0
    selected="$colors_dir/$selected"
  fi

  if [[ ! -f "$selected" ]]; then
    echo "Theme not found: $selected" >&2
    exit 1
  fi

  if [[ "$(basename "$selected")" != "current.css" ]]; then
    ln -sf "$selected" "$current_css"
  fi
}

update_waybar_import() {
  local import_url="file://$current_css"
  if [[ ! -f "$waybar_style" ]]; then
    echo "Waybar style not found: $waybar_style" >&2
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  awk -v repl="@import url(\"$import_url\");" '
    BEGIN { replaced=0 }
    /^[[:space:]]*@import url\("file:\/\/[^"]*\/\.config\/colors\/[^"]+\.css"\);/ {
      print repl;
      replaced=1;
      next
    }
    { print }
    END {
      if (replaced == 0) {
        print "No matching @import found in waybar style." > "/dev/stderr"
      }
    }
  ' "$waybar_style" > "$tmp"
  mv "$tmp" "$waybar_style"
}

select_theme "${1:-}"
update_waybar_import

css_file="$current_css"

awk '
  /@define-color/ {
    name=$2;
    value=$3;
    gsub(/;/, "", value);
    colors[name]=value;
  }
  function need(name) {
    if (!(name in colors)) {
      missing = missing name " ";
    }
  }
  END {
    need("wb-bg");
    need("wb-fg");
    need("wb-bg-dark");
    need("wb-bg-highlight");
    need("wb-fg-dark");
    need("wb-red");
    need("wb-green");
    need("wb-yellow");
    need("wb-blue");
    need("wb-magenta");
    need("wb-cyan");

    if (missing != "") {
      print "Missing colors in " css ": " missing > "/dev/stderr";
      exit 1;
    }

    bg = colors["wb-bg"];
    fg = colors["wb-fg"];
    nb = colors["wb-bg-dark"];
    nw = colors["wb-fg-dark"];
    bb = colors["wb-bg-highlight"];
    bw = colors["wb-fg"];
    r  = colors["wb-red"];
    g  = colors["wb-green"];
    y  = colors["wb-yellow"];
    b  = colors["wb-blue"];
    m  = colors["wb-magenta"];
    c  = colors["wb-cyan"];

    print "# Generated from " css;
    print "[colors.primary]";
    print "background = \"" bg "\"";
    print "foreground = \"" fg "\"";
    print "";
    print "[colors.normal]";
    print "black = \"" nb "\"";
    print "red = \"" r "\"";
    print "green = \"" g "\"";
    print "yellow = \"" y "\"";
    print "blue = \"" b "\"";
    print "magenta = \"" m "\"";
    print "cyan = \"" c "\"";
    print "white = \"" nw "\"";
    print "";
    print "[colors.bright]";
    print "black = \"" bb "\"";
    print "red = \"" r "\"";
    print "green = \"" g "\"";
    print "yellow = \"" y "\"";
    print "blue = \"" b "\"";
    print "magenta = \"" m "\"";
    print "cyan = \"" c "\"";
    print "white = \"" bw "\"";
  }
' css="$css_file" "$css_file" > "$out_file"

awk '
  /@define-color/ {
    name=$2;
    value=$3;
    gsub(/;/, "", value);
    colors[name]=value;
  }
  function need(name) {
    if (!(name in colors)) {
      missing = missing name " ";
    }
  }
  END {
    need("wb-bg");
    need("wb-fg");
    need("wb-bg-popup");
    need("wb-border");
    need("wb-accent");
    need("wb-bg-popup");
    need("wb-fg-gutter");
    need("wb-orange");
    need("wb-red");

    if (missing != "") {
      print "Missing colors in " css ": " missing > "/dev/stderr";
      exit 1;
    }

    bg = colors["wb-bg"];
    fg = colors["wb-fg"];
    bg_alt = colors["wb-bg-popup"];
    border = colors["wb-border"];
    sel = colors["wb-accent"];
    urgent = colors["wb-red"];

    print "/* Generated from " css " */";
    print "* {";
    print "  background: " bg ";";
    print "  background-alt: " bg_alt ";";
    print "  foreground: " fg ";";
    print "  selected: " sel ";";
    print "  border-color: " border ";";
    print "  separatorcolor: " border ";";
    print "  urgent: " urgent ";";
    print "}";
  }
' css="$css_file" "$css_file" > "$rofi_colors"

chrome_dir="$librewolf_profile/chrome"
mkdir -p "$chrome_dir"
userchrome_file="$chrome_dir/userChrome.css"
usercontent_file="$chrome_dir/userContent.css"

awk '
  /@define-color/ {
    name=$2;
    value=$3;
    gsub(/;/, "", value);
    colors[name]=value;
  }
  function need(name) {
    if (!(name in colors)) {
      missing = missing name " ";
    }
  }
  END {
    need("wb-bg");
    need("wb-bg-dark");
    need("wb-bg-highlight");
    need("wb-fg");
    need("wb-fg-dark");
    need("wb-border");
    need("wb-accent");

    if (missing != "") {
      print "Missing colors in " css ": " missing > "/dev/stderr";
      exit 1;
    }

    bg = colors["wb-bg"];
    bg_dark = colors["wb-bg-dark"];
    bg_hi = colors["wb-bg-highlight"];
    fg = colors["wb-fg"];
    fg_dark = colors["wb-fg-dark"];
    border = colors["wb-border"];
    accent = colors["wb-accent"];
    bg_popup = colors["wb-bg-popup"];
    fg_gutter = colors["wb-fg-gutter"];
    orange = colors["wb-orange"];

    print "/* Generated from " css " */";
    print "@-moz-document url(\"chrome://browser/content/browser.xhtml\") {";
    print "  :root {";
    print "    --wb-bg: " bg ";";
    print "    --wb-bg-dark: " bg_dark ";";
    print "    --wb-bg-highlight: " bg_hi ";";
    print "    --wb-fg: " fg ";";
    print "    --wb-fg-dark: " fg_dark ";";
    print "    --wb-border: " border ";";
    print "    --wb-accent: " accent ";";
    print "    --wb-toolbar-field: " bg_hi ";";
    print "    --wb-toolbar-field-focus: " fg_gutter ";";
    print "    --wb-toolbar-field-border: " bg_popup ";";
    print "    --wb-toolbar-field-border-focus: " orange ";";
    print "    --wb-toolbar-field-text: " fg_dark ";";
    print "    --wb-toolbar-field-text-focus: " fg ";";
    print "  }";
    print "  #navigator-toolbox, #nav-bar, #TabsToolbar {";
    print "    background-color: var(--wb-bg) !important;";
    print "    color: var(--wb-fg) !important;";
    print "  }";
    print "  .tab-background {";
    print "    background-color: var(--wb-bg-dark) !important;";
    print "    border-color: var(--wb-border) !important;";
    print "  }";
    print "  .tab-background[selected] {";
    print "    background-color: var(--wb-bg-highlight) !important;";
    print "  }";
    print "  .tab-label {";
    print "    color: var(--wb-fg) !important;";
    print "  }";
    print "  #urlbar-background {";
    print "    background-color: var(--wb-toolbar-field) !important;";
    print "    border-color: var(--wb-toolbar-field-border) !important;";
    print "  }";
    print "  #urlbar[focused] #urlbar-background,";
    print "  #urlbar[open] #urlbar-background,";
    print "  #urlbar[breakout][breakout-extend] #urlbar-background,";
    print "  #urlbar:focus-within #urlbar-background,";
    print "  #urlbar-container:focus-within #urlbar-background {";
    print "    background-color: var(--wb-toolbar-field-focus) !important;";
    print "    border-color: var(--wb-toolbar-field-border-focus) !important;";
    print "    box-shadow: 0 0 0 1px var(--wb-toolbar-field-border-focus) !important;";
    print "  }";
    print "  #urlbar-input {";
    print "    color: var(--wb-toolbar-field-text) !important;";
    print "  }";
    print "  #urlbar[focused] #urlbar-input,";
    print "  #urlbar[open] #urlbar-input,";
    print "  #urlbar:focus-within #urlbar-input {";
    print "    color: var(--wb-toolbar-field-text-focus) !important;";
    print "  }";
    print "  #toolbar-menubar, #PersonalToolbar {";
    print "    background-color: var(--wb-bg) !important;";
    print "    color: var(--wb-fg-dark) !important;";
    print "  }";
    print "  .urlbarView-row[selected] {";
    print "    background-color: var(--wb-bg-highlight) !important;";
    print "  }";
    print "  .urlbarView-row[selected] .urlbarView-url {";
    print "    color: var(--wb-accent) !important;";
    print "  }";
    print "}";
  }
' css="$css_file" "$css_file" > "$userchrome_file"

awk '
  /@define-color/ {
    name=$2;
    value=$3;
    gsub(/;/, "", value);
    colors[name]=value;
  }
  function need(name) {
    if (!(name in colors)) {
      missing = missing name " ";
    }
  }
  END {
    need("wb-bg");
    need("wb-fg");
    need("wb-accent");

    if (missing != "") {
      print "Missing colors in " css ": " missing > "/dev/stderr";
      exit 1;
    }

    bg = colors["wb-bg"];
    fg = colors["wb-fg"];
    accent = colors["wb-accent"];

    print "/* Generated from " css " */";
    print ":root {";
    print "  --wb-bg: " bg ";";
    print "  --wb-fg: " fg ";";
    print "  --wb-accent: " accent ";";
    print "}";
    print "@-moz-document url-prefix(\"about:\") {";
    print "  body, html {";
    print "    background: var(--wb-bg) !important;";
    print "    color: var(--wb-fg) !important;";
    print "  }";
    print "  a {";
    print "    color: var(--wb-accent) !important;";
    print "  }";
    print "}";
  }
' css="$css_file" "$css_file" > "$usercontent_file"

awk '
  /@define-color/ {
    name=$2;
    value=$3;
    gsub(/;/, "", value);
    colors[name]=value;
  }
  function need(name) {
    if (!(name in colors)) {
      missing = missing name " ";
    }
  }
  END {
    need("wb-bg");
    need("wb-fg-dark");
    need("wb-border");

    if (missing != "") {
      print "Missing colors in " css ": " missing > "/dev/stderr";
      exit 1;
    }

    bg = colors["wb-bg"];
    fg = colors["wb-fg-dark"];
    border = colors["wb-border"];

    print "background-color=" bg;
    print "text-color=" fg;
    print "border-color=" border;
  }
' css="$css_file" "$css_file" > "$mako_colors"

bg_color="$(awk '/@define-color[[:space:]]+wb-bg/ {gsub(/;/,"",$3); print $3; exit}' "$css_file")"
pkill swaybg >/dev/null 2>&1 || true
swaybg -c "${bg_color:-#1a1b26}" >/dev/null 2>&1 &

pkill mako >/dev/null 2>&1 || true
mako >/dev/null 2>&1 &

pkill waybar; waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &
