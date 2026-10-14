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
