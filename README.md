# MeoArch OS Workspace

This repository is the main ISO assembly workspace.

`MeoArch os/` is the existing archiso profile and keeps its current name. Do not
rename it unless the project decides to migrate the profile path later.

## Layout

```text
MeoArch_os-workspace/
├── MeoArch os/          # Existing archiso profile
├── configs/             # System configuration staged outside airootfs
│   ├── systemd/
│   ├── pacman/
│   ├── zsh/
│   └── network/
├── themes/              # GTK, Qt, GRUB, SDDM, and UI themes
├── scripts/             # Build and install entrypoints
├── assets/              # Wallpapers, icons, fonts
│   ├── wallpapers/
│   ├── icons/
│   └── fonts/
├── docs/
└── README.md
```

## Split Repository Rule

Only split code or assets into another repository when they can be reused
independently from this ISO workspace.

Likely future split candidates:

- `MeoUI` from `themes/MeoUI`
- logos and fonts from `assets/`
- installer docs from `docs/`
- installer source when it becomes a real standalone app

The main workspace should stay focused on assembling the ISO.

