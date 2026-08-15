# MeoArch OS Production Readiness Capability Matrix

| Component | Implemented | Source of Truth | Build Tested | Runtime Tested | VM Tested | Real Hardware Tested | Failure Tested | Known Limitations | Blocking Release? |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- | :---: |
| **Bootloader (GRUB)** | Yes | `meoarch-os/grub/grub.cfg` | Yes | Yes | Yes | UNVERIFIED | Yes | High-res gfxterm menu with background splash | **P0 (Pass)** |
| **Bootloader (systemd-boot)** | Yes | `efiboot/loader/entries/01-archiso-linux.conf` | Yes | Yes | Yes | UNVERIFIED | Yes | Quiet splash options configured | **P0 (Pass)** |
| **Plymouth Boot Splash** | Yes | `themes/plymouth/meoarch` | Yes | Yes | Yes | UNVERIFIED | Yes | Multi-res responsive layout, Esc to console | **P0 (Pass)** |
| **Meo Boot Status Bridge** | Yes | `installer/bin/meo-boot-status` | Yes | Yes | Yes | UNVERIFIED | Yes | Discrete progress weights (5..100%), json telemetry | **P0 (Pass)** |
| **Cage Kiosk Lifecycle** | Yes | `installer/bin/meoarch-installer-kiosk` | Yes | Yes | Yes | UNVERIFIED | Yes | Auto-detects DRM display geometry | **P0 (Pass)** |
| **Installer Host (QML/C++)** | Yes | `installer/app/main.cpp` | Yes | Yes | Yes | UNVERIFIED | Yes | Qt 6 Wayland native C++ runner | **P0 (Pass)** |
| **Privilege Boundary** | Yes | `meoarch-installer.service` | Yes | Yes | Yes | UNVERIFIED | Yes | UI runs unprivileged; backend RPC scoped | **P0 (Pass)** |
| **Network Management** | Yes | `installer/backend/hardware.py` / NM | Yes | Yes | Yes | UNVERIFIED | Yes | NetworkManager secret API; no PSK log leaks | **P0 (Pass)** |
| **Storage & Enumeration** | Yes | `installer/backend/hardware.py` | Yes | Yes | Yes | UNVERIFIED | Yes | Uses `/dev/disk/by-id`; protects Live ISO medium | **P0 (Pass)** |
| **Partitioning (Erase Disk)** | Yes | `installer/backend/generate-config.py` | Yes | Yes | Yes | UNVERIFIED | Yes | GPT layout for UEFI, root + ESP | **P0 (Pass)** |
| **Encryption (LUKS)** | Yes | Archinstall LUKS generator | Yes | Yes | Yes | UNVERIFIED | Yes | Passphrase zeroed in memory after use | **P1 (Pass)** |
| **Account & Security** | Yes | `apply-target-customizations.sh` | Yes | Yes | Yes | UNVERIFIED | Yes | User, UID, sudo, hostname, SDDM autologin | **P0 (Pass)** |
| **Locale & Timezone** | Yes | `generate-config.py` | Yes | Yes | Yes | UNVERIFIED | Yes | System locale, keyboard layout, timezone | **P0 (Pass)** |
| **Hardware Detection** | Yes | `installer/backend/hardware.py` | Yes | Yes | Yes | UNVERIFIED | Yes | PCI ID vendor driver mapping (AMD/Intel/NVIDIA) | **P0 (Pass)** |
| **Base Packages** | Yes | `meoarch-os/packages.x86_64` | Yes | Yes | Yes | UNVERIFIED | Yes | Official Arch Linux stable repositories | **P0 (Pass)** |
| **Archinstall Integration** | Yes | `run-archinstall.sh` | Yes | Yes | Yes | UNVERIFIED | Yes | Version-pinned JSON configuration runner | **P0 (Pass)** |
| **MeoUI Runtime** | Yes | `projects/meo-ui` | Yes | Yes | Yes | UNVERIFIED | Yes | QML Material 3 design system module | **P0 (Pass)** |
| **Meo.System Backend** | Yes | `meo-system` native module | Yes | Yes | Yes | UNVERIFIED | Yes | Native C++/Qt NetworkManager & SystemState | **P0 (Pass)** |
| **Meo Desktop Payload** | Yes | `meo-kde` look-and-feel / plasmoids | Yes | Yes | Yes | UNVERIFIED | Yes | Theme, color schemes, topbar, shelf plasmoids | **P0 (Pass)** |
| **OmniStore Provisioning** | Yes | `data/omnistore/provisioning.json` | Yes | Yes | Yes | UNVERIFIED | Yes | Post-install first-login confirmation workflow | **P1 (Pass)** |
| **Target OS Validation** | Yes | `scripts/verify-target-install.sh` | Yes | Yes | Yes | UNVERIFIED | Yes | Automated chroot sanity checks | **P0 (Pass)** |
| **ISO Generation** | Yes | `scripts/build-iso.sh` | Yes | Yes | Yes | UNVERIFIED | Yes | Uniquely timestamped ISO build & provenance manifest | **P0 (Pass)** |
| **UEFI Boot** | Yes | `mkarchiso` systemd-boot | Yes | Yes | Yes | UNVERIFIED | Yes | Verified on OVMF 4m UEFI firmware | **P0 (Pass)** |
