# Steamify GNOME theme

The SteamOS look for GNOME, the counterpart of the Vapor theme on KDE Plasma
(`cachyos-vapor`). Used by [Steamify CachyOS](https://github.com/theupriser/steamify-cachyos)
as its "SteamOS theme for GNOME" option, and usable on its own.

What it sets up (all of it undoable):

- **Colors** of Vapor: dark mode, GTK4/libadwaita colors (`gtk-4.0/gtk.css`), the GNOME Shell top bar and dash in Vapor's panel color `#24272c`, Vapor's blue accents (the stylesheet of the *Steamify Vapor* extension, `extensions/steamify-vapor@steamify.github.io/`, which also starts GNOME on the desktop, not the overview).
- **The Steam Deck wallpaper** from `cachyos-vapor`.
- **Extensions** that make GNOME look and behave like Ubuntu's: Desktop Icons NG (icons on the desktop), AppIndicator (tray icons, e.g. Steam), Dash to Dock (what Ubuntu Dock is based on), and the Steamify Vapor extension. No more than those four.

Install with `./install.sh`, remove with `./uninstall.sh`.

Status: prototype, made alongside Steamify's GNOME support (steamify-cachyos, `feature/gnome-prototype`).

## GNOME Settings with a "GNOME Desktop" panel

Ubuntu manages the dock, the desktop icons and tiling in its own panel inside GNOME Settings. GNOME Settings
can't load panels as plug-ins, so `settings/` builds the same Settings app (Arch's 51.1) with Ubuntu's panel added,
shown as **GNOME Desktop** under Appearance:

    cd settings && makepkg -si

A prebuilt package is on the [`settings` release](../../releases/tag/settings) (built by GitHub Actions on current
Arch, rebuilt every week), so the several minutes of compiling can be skipped: download
`steamify-gnome-control-center-x86_64.pkg.tar.zst` and its `.sha256`, check it with `sha256sum -c`, then
`sudo pacman -U --ask 4 steamify-gnome-control-center-x86_64.pkg.tar.zst`.

It replaces the `gnome-control-center` package (it provides it). The panel is Ubuntu's, ported from GNOME 50 to 51
(two API changes in `panel/cc-ubuntu-panel.c`); the install script puts the extensions' settings schemas in
`~/.local/share/glib-2.0/schemas`, where the panel looks for them. Dock and Enhanced Tiling show up once their
extensions are loaded, which is after the next login.
