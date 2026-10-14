#!/bin/bash
# Undo install.sh: the settings as they were, our files removed. Packages stay installed.
set -uo pipefail
data="${XDG_DATA_HOME:-$HOME/.local/share}"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
backup="${XDG_STATE_HOME:-$HOME/.local/state}/steamify-gnome-theme"
if [[ -f "$backup/gsettings" ]]; then
    while read -r schema key value; do gsettings set "$schema" "$key" "$value" 2>/dev/null; done < <(tac "$backup/gsettings")
fi
if [[ -f "$backup/gtk.css" ]]; then mv -f "$backup/gtk.css" "$config/gtk-4.0/gtk.css"
elif grep -qF "/* Steamify GNOME theme */" "$config/gtk-4.0/gtk.css" 2>/dev/null; then rm -f "$config/gtk-4.0/gtk.css"; fi
rm -f "$data"/applications/steamify-{dock,icons}-settings.desktop
rm -rf "$data/gnome-shell/extensions/steamify-vapor@steamify.github.io" \
    "$data/gnome-shell/extensions/ubuntu-dock@ubuntu.com" "$data/gnome-shell/extensions/tiling-assistant@ubuntu.com" \
    "$data/gnome-background-properties/steamify-steamos.xml" "$backup"
echo "Done. Log out and in again."
