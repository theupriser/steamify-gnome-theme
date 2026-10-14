#!/bin/bash
# Steamify GNOME theme: the SteamOS (Vapor) look for GNOME, with the extensions
# Ubuntu uses. For CachyOS/Arch with GNOME; run as your user (it uses sudo for
# packages). Undo with ./uninstall.sh.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
backup="${XDG_STATE_HOME:-$HOME/.local/state}/steamify-gnome-theme"
mark="/* Steamify GNOME theme */"
dock_url="https://github.com/micheleg/dash-to-dock/releases/download/extensions.gnome.org-v110/dash-to-dock@micxgx.gmail.com.zip"
dock_sha256=3e60680fe7217b905aac4f10deb042e39fcf49168c9b8fdcc5a711bdd49bd3d2
uuids=(ding@rastersoft.com appindicatorsupport@rgcjonas.gmail.com dash-to-dock@micxgx.gmail.com steamify-vapor@steamify.github.io)

mkdir -p "$backup"
gset() {
    # gset <schema> <key> <value>: gsettings, remembering the old value once for uninstall.sh.
    gsettings get "$1" "$2" >/dev/null 2>&1 || return 0
    grep -qxF "$1 $2" <(cut -d' ' -f1-2 "$backup/gsettings" 2>/dev/null) ||
        printf '%s %s %s\n' "$1" "$2" "$(gsettings get "$1" "$2")" >> "$backup/gsettings"
    gsettings set "$1" "$2" "$3"
}

# 1. Packages: desktop icons, tray icons, the Steam Deck wallpapers.
sudo pacman -S --needed --noconfirm gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator cachyos-vapor

# 2. Dash to Dock (what Ubuntu Dock is based on): upstream's release, pinned; the packaged one lags behind GNOME.
dock="$data/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
zip="$(mktemp --suffix=.zip)"
curl -fsSL "$dock_url" -o "$zip"
[[ "$(sha256sum < "$zip")" == "$dock_sha256  -" ]] || { echo "The dock download doesn't match its checksum." >&2; exit 1; }
rm -rf "$dock"; mkdir -p "$dock"
python3 -c 'import sys,zipfile;zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$zip" "$dock"
glib-compile-schemas "$dock/schemas"
rm -f "$zip"

# 3. Our extension (the shell colors as its stylesheet, and start on the desktop, not in the overview), the GTK4 colors.
mkdir -p "$data/gnome-shell/extensions" "$config/gtk-4.0"
rm -rf "$data/gnome-shell/extensions/steamify-vapor@steamify.github.io"
cp -r "$here/extensions/steamify-vapor@steamify.github.io" "$data/gnome-shell/extensions/"
if [[ -f "$config/gtk-4.0/gtk.css" ]] && ! grep -qF "$mark" "$config/gtk-4.0/gtk.css"; then cp -a "$config/gtk-4.0/gtk.css" "$backup/gtk.css"; fi
{ echo "$mark"; cat "$here/gtk-4.0/gtk.css"; } > "$config/gtk-4.0/gtk.css"

# GNOME Settings has no "Ubuntu Desktop" panel (Ubuntu's own patch): launchers for the extensions' preferences stand in for it.
mkdir -p "$data/applications"
for entry in "dock|Dock Settings|dash-to-dock@micxgx.gmail.com" "icons|Desktop Icons Settings|ding@rastersoft.com"; do
    IFS='|' read -r id name uuid <<< "$entry"
    printf '%s\n' '[Desktop Entry]' 'Type=Application' "Name=$name" "Exec=gnome-extensions prefs $uuid" \
        'Icon=preferences-desktop' 'Categories=Settings;DesktopSettings;GTK;' > "$data/applications/steamify-$id-settings.desktop"
done

# 4. Settings.
gset org.gnome.desktop.interface color-scheme "'prefer-dark'"
gset org.gnome.desktop.interface accent-color "'blue'"
wallpaper="/usr/share/wallpapers/Steam Deck Logo Default.jpg"
if [[ -f "$wallpaper" ]]; then
    for key in picture-uri picture-uri-dark; do gset org.gnome.desktop.background $key "'file://${wallpaper// /%20}'"; done
    gset org.gnome.desktop.background picture-options "'zoom'"
fi
d=org.gnome.shell.extensions.dash-to-dock
gset $d dock-position "'LEFT'"; gset $d dock-fixed true   # its shape (panel or floating) is yours: Dock Settings
gset $d transparency-mode "'FIXED'"; gset $d custom-background-color true; gset $d background-color "'#24272c'"
gset $d background-opacity 0.95; gset $d running-indicator-style "'DOTS'"; gset $d custom-theme-shrink true
enabled="$(gsettings get org.gnome.shell enabled-extensions)"
for uuid in "${uuids[@]}"; do
    [[ "$enabled" == *"$uuid"* ]] && continue
    if [[ "$enabled" == "@as []" || "$enabled" == "[]" ]]; then enabled="['$uuid']"; else enabled="${enabled%]}, '$uuid']"; fi
done
gset org.gnome.shell enabled-extensions "$enabled"
echo "Done. Log out and in again: GNOME loads new extensions and the shell theme at login."
