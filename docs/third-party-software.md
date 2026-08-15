# MeoArch OS Third-Party Software & License Audit

| Package / Payload Component | Upstream Source | License | Redistribution Allowed? | Source Availability Requirement | Audit Notes |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **Arch Linux Base Packages** | Arch Linux Repositories | GPL-2.0 / GPL-3.0 / MIT / BSD | Yes | Yes (Open Source) | Pulled via pacstrap from official HTTPS mirrors |
| **Qt 6 Framework (Declarative/Wayland)** | Qt Project | LGPL-3.0 / GPL-3.0 | Yes | Yes (Dynamic Linking) | Dynamically linked against system Qt 6 shared objects |
| **Cage Wayland Kiosk** | Cage / wlroots | MIT | Yes | Yes | Open-source Wayland kiosk compositor |
| **Plymouth Boot Splash** | Freedesktop / Plymouth | GPL-2.0-or-later | Yes | Yes | Standard Linux boot splash renderer |
| **MeoUI Component Library** | MeoArch (`meo-ui`) | MIT | Yes | Yes | First-party QML Material Design 3 library |
| **Meo.System Native Module** | MeoArch (`meo-system`) | MIT | Yes | Yes | Native NetworkManager and system state plugin |
| **Meo Desktop Look-and-Feel** | MeoArch (`meo-kde`) | MIT / LGPL | Yes | Yes | Custom KDE Plasma themes and plasmoids |
| **OmniStore App Store** | MeoArch (`omnistore`) | MIT | Yes | Yes | First-party application manager & provisioning client |
