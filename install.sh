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
# Ubuntu's own builds (the more mature ones): Ubuntu Dock from its source tag, Tiling Assistant from its release.
dock_url="https://github.com/micheleg/dash-to-dock/archive/refs/tags/ubuntu-dock-109ubuntu2.tar.gz"
dock_sha256=599057fa27d922d4730bfc27c803b1b14b05f49a20e580e154e151b8481e5d41
tiling_url="https://github.com/ubuntu/Tiling-Assistant/releases/download/v56/tiling-assistant@leleat-on-github.shell-extension.zip"
tiling_sha256=961da0c6b8e5960770e68a06d71205765870435dbe8fe0ccc1ec50d4cc78265a
uuids=(ding@rastersoft.com appindicatorsupport@rgcjonas.gmail.com ubuntu-dock@ubuntu.com tiling-assistant@ubuntu.com steamify-vapor@steamify.github.io)

mkdir -p "$backup"
gset() {
    # gset <schema> <key> <value>: gsettings, remembering the old value once for uninstall.sh.
    gsettings get "$1" "$2" >/dev/null 2>&1 || return 0
    grep -qxF "$1 $2" <(cut -d' ' -f1-2 "$backup/gsettings" 2>/dev/null) ||
        printf '%s %s %s\n' "$1" "$2" "$(gsettings get "$1" "$2")" >> "$backup/gsettings"
    gsettings set "$1" "$2" "$3"
}

# 1. Packages: desktop icons, tray icons, Extension Manager (to switch extensions and open their settings), the Steam Deck wallpapers.
sudo pacman -S --needed --noconfirm gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator extension-manager cachyos-vapor

# 2. Ubuntu Dock (built from source: make, sassc, gettext) and Tiling Assistant, both pinned and checked.
sudo pacman -S --needed --noconfirm make sassc gettext
work="$(mktemp -d)"
curl -fsSL "$dock_url" -o "$work/dock.tar.gz"
[[ "$(sha256sum < "$work/dock.tar.gz")" == "$dock_sha256  -" ]] || { echo "The dock download doesn't match its checksum." >&2; exit 1; }
mkdir "$work/dock" && tar xzf "$work/dock.tar.gz" -C "$work/dock" --strip-components=1
mkdir -p "$data/gnome-shell/extensions"
make -C "$work/dock" install-local INSTALLBASE="$data/gnome-shell/extensions" >/dev/null
tiling="$data/gnome-shell/extensions/tiling-assistant@ubuntu.com"
curl -fsSL "$tiling_url" -o "$work/tiling.zip"
[[ "$(sha256sum < "$work/tiling.zip")" == "$tiling_sha256  -" ]] || { echo "The tiling download doesn't match its checksum." >&2; exit 1; }
rm -rf "$tiling"; mkdir -p "$tiling"
python3 -c 'import sys,zipfile;zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$work/tiling.zip" "$tiling"
# Under the name Ubuntu gives it (Ubuntu's Settings panel looks for it).
sed -i 's|"uuid": "tiling-assistant@leleat-on-github"|"uuid": "tiling-assistant@ubuntu.com"|' "$tiling/metadata.json"
glib-compile-schemas "$tiling/schemas"
rm -rf "$work"

# 3. Our extension (the shell colors as its stylesheet, and start on the desktop, not in the overview), the GTK4 colors.
mkdir -p "$data/gnome-shell/extensions" "$config/gtk-4.0"
rm -rf "$data/gnome-shell/extensions/steamify-vapor@steamify.github.io"
cp -r "$here/extensions/steamify-vapor@steamify.github.io" "$data/gnome-shell/extensions/"
if [[ -f "$config/gtk-4.0/gtk.css" ]] && ! grep -qF "$mark" "$config/gtk-4.0/gtk.css"; then cp -a "$config/gtk-4.0/gtk.css" "$backup/gtk.css"; fi
{ echo "$mark"; cat "$here/gtk-4.0/gtk.css"; } > "$config/gtk-4.0/gtk.css"

# The SteamOS wallpapers in GNOME Settings' background list.
bgxml="$data/gnome-background-properties/steamify-steamos.xml"
mkdir -p "$(dirname "$bgxml")"
{
    printf '%s\n' '<?xml version="1.0"?>' '<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">' '<wallpapers>'
    for f in /usr/share/wallpapers/*.jpg; do
        [[ -f "$f" ]] || continue
        printf '  <wallpaper deleted="false">\n    <name>SteamOS: %s</name>\n    <filename>%s</filename>\n    <filename-dark>%s</filename-dark>\n    <options>zoom</options>\n    <pcolor>#24272c</pcolor>\n    <scolor>#24272c</scolor>\n    <shade_type>solid</shade_type>\n  </wallpaper>\n' "$(basename "$f" .jpg)" "$f" "$f"
    done
    echo '</wallpapers>'
} > "$bgxml"

# 4. Settings.
gset org.gnome.desktop.interface color-scheme "'prefer-dark'"
gset org.gnome.desktop.interface accent-color "'blue'"
# Windows with minimize and maximize buttons, like Ubuntu (GNOME shows only close by default).
gset org.gnome.desktop.wm.preferences button-layout "'appmenu:minimize,maximize,close'"
wallpaper="/usr/share/wallpapers/Steam Deck Logo Default.jpg"
if [[ -f "$wallpaper" ]]; then
    for key in picture-uri picture-uri-dark; do gset org.gnome.desktop.background $key "'file://${wallpaper// /%20}'"; done
    gset org.gnome.desktop.background picture-options "'zoom'"
fi
d=org.gnome.shell.extensions.dash-to-dock
gset $d dock-position "'LEFT'"; gset $d dock-fixed true   # its shape (panel or floating) is yours: Dock Settings
gset org.gnome.shell.extensions.ding show-trash false   # the trash is in the dock, not on the desktop
gset $d click-action "'minimize-or-previews'"; gset $d show-trash true; gset $d running-indicator-style "'DOTS'";
enabled="$(gsettings get org.gnome.shell enabled-extensions)"
for uuid in "${uuids[@]}"; do
    [[ "$enabled" == *"$uuid"* ]] && continue
    if [[ "$enabled" == "@as []" || "$enabled" == "[]" ]]; then enabled="['$uuid']"; else enabled="${enabled%]}, '$uuid']"; fi
done
gset org.gnome.shell enabled-extensions "$enabled"
echo "Done. Log out and in again: GNOME loads new extensions and the shell theme at login."
