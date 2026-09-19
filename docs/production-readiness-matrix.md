# MeoArch OS Production Readiness Capability Matrix

> **2026-09-17 current-candidate reconciliation.** Historical `Yes` entries
> are not evidence that the currently checked-out ISO profile is releasable.
> The current `meoarch-os/` profile is dirty and the maintained build script
> refuses to archive it as a candidate. Source/static checks, a built ISO,
> Live-ISO boot, installed-target boot, and physical-hardware acceptance remain
> separate evidence layers. The rows below record known current blockers rather
> than carrying forward contradicted claims.

| Component | Implemented | Source of Truth | Build Tested | Runtime Tested | VM Tested | Real Hardware Tested | Failure Tested | Known Limitations | Blocking Release? |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- | :---: |
| **Bootloader (GRUB)** | Yes | `meoarch-os/grub/grub.cfg` | Yes | Yes | Yes | UNVERIFIED | Yes | High-res gfxterm menu with background splash | **P0 (Pass)** |
| **Bootloader (systemd-boot)** | Yes | `efiboot/loader/entries/01-archiso-linux.conf` | Yes | Yes | Yes | UNVERIFIED | Yes | Quiet splash options configured | **P0 (Pass)** |
| **Plymouth Boot Splash** | Yes | `themes/plymouth/meoarch` | Yes | Yes | Yes | UNVERIFIED | Yes | Multi-res responsive layout, Esc to console | **P0 (Pass)** |
| **Meo Boot Status Bridge** | Yes | `installer/bin/meo-boot-status` | Yes | Yes | Yes | UNVERIFIED | Yes | Discrete progress weights (5..100%), json telemetry | **P0 (Pass)** |
| **Cage Kiosk Lifecycle** | Yes | `installer/bin/meoarch-installer-kiosk` | Yes | Yes | Yes | UNVERIFIED | Yes | Auto-detects DRM display geometry | **P0 (Pass)** |
| **Installer Host (QML/C++)** | Yes | `installer/app/main.cpp` | Yes | Yes | Yes | UNVERIFIED | Yes | Qt 6 Wayland native C++ runner | **P0 (Pass)** |
| **Live environment / target desktop split** | Partial | `meoarch-installer.service`, `packages.x86_64`, ISO validation scripts | Source-only | UNVERIFIED | UNVERIFIED | UNVERIFIED | UNVERIFIED | Live session is Cage kiosk; Plasma Login Manager and `plasma.desktop` are target-system payload, not Live ISO content | **P0 (Open)** |
| **Privilege Boundary** | Yes | `meoarch-installer.service` | Yes | Yes | Yes | UNVERIFIED | Yes | UI runs unprivileged; backend RPC scoped | **P0 (Pass)** |
| **Network Management** | Yes | `installer/backend/hardware.py` / NM | Yes | Yes | Yes | UNVERIFIED | Yes | NetworkManager secret API; no PSK log leaks | **P0 (Pass)** |
| **Storage & Enumeration** | Yes | `installer/backend/hardware.py` | Yes | Yes | Yes | UNVERIFIED | Yes | Uses `/dev/disk/by-id`; protects Live ISO medium | **P0 (Pass)** |
| **Partitioning (Erase Disk)** | Yes | `installer/backend/generate-config.py` | Yes | Yes | Yes | UNVERIFIED | Yes | GPT layout for UEFI, root + ESP | **P0 (Pass)** |
| **Encryption (LUKS)** | **No — blocked by current generator** | `installer/backend/generate-config.py` (`diskEncryption` rejection) and its regression test | Source rejection tested | No | No | UNVERIFIED | No | `cryptsetup` in the Live image does not wire an encrypted install; passphrase lifecycle, Archinstall configuration, recovery and UEFI VM proof are still required | **P0 (Blocked when encryption is a release requirement)** |
| **Account & Security / target login** | Partial | `generate-config.py`, `apply-target-customizations.sh`, `plasmalogin.service` | Source-only | UNVERIFIED | UNVERIFIED | UNVERIFIED | UNVERIFIED | User/UID/sudo/hostname flow is separate from target login. Automatic login is explicitly disabled and `SDDM autologin` is not a current feature; target design enables Plasma Login Manager | **P0 (Open)** |
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
