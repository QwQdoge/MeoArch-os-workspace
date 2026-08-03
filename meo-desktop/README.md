# Meo Desktop

Meo Desktop is the KDE Plasma desktop profile for MeoArch. It configures
upstream Plasma first and keeps application UI in the shared `MeoUI` QML
module under `themes/MeoUI`.

This first vertical slice provides a deterministic bottom shelf, application
launcher, task manager, system tray, clock, MeoArch wallpaper, safe developer
apply/reset scripts, and Arch package definitions. Network, Bluetooth, audio,
brightness, notifications, overview, and power continue to use KDE services
and widgets rather than private replacements.

Use `setup/apply-meo-desktop.sh --dry-run` before applying it to a development
account. VM and disposable XDG directories are the supported test targets.
