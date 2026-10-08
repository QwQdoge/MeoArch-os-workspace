# MeoArch OS Production Readiness Capability Matrix

> **2026-10-08 architecture reconciliation.** Historical `Yes` entries are not
> evidence that the current ISO candidate is releasable. Source/static checks,
> a built ISO, Live-ISO boot, installed-target boot, repeated VM installation,
> and physical-hardware acceptance are separate evidence layers. This matrix
> records the current intended architecture and known blockers; it must not
> promote stale acceptance results into current runtime truth.
>
> Current boot contract: `meoarch-os/profiledef.sh` declares
> `bios.syslinux` + `uefi.grub`. The old systemd-boot rows/wording are obsolete
> for the current profile. Current Live UX contract: Plasma Wayland is the
> normal Live desktop, with the Installer opened full-screen on top; Cage is an
> optional kiosk/fallback path, not the canonical normal Live session.

| Component | Implemented | Source of Truth | Build Tested | Runtime Tested | VM Tested | Real Hardware Tested | Failure Tested | Known Limitations | Blocking Release? |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- | :---: |
| **BIOS Bootloader (Syslinux)** | Yes | `meoarch-os/profiledef.sh`, `meoarch-os/syslinux/` | Source-configured | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Legacy BIOS rescue-media path kept for broad compatibility | **P0 (Verify)** |
| **UEFI Bootloader (GRUB)** | Yes | `meoarch-os/profiledef.sh`, `meoarch-os/grub/` | Source-configured | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Canonical UEFI Live boot path; branded installer/diagnostics menu | **P0 (Verify)** |
| **Plymouth Boot Splash** | Yes | `themes/plymouth/meoarch` | Source-tested historically | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Must be revalidated with current GRUB/Live path and target boot | **P0 (Verify)** |
| **Meo Boot Status Bridge** | Yes | `installer/bin/meo-boot-status` | Source-tested historically | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Discrete progress telemetry; runtime evidence still required | **P0 (Verify)** |
| **Plasma Wayland Live Session** | Partial | Live-session staging/service files, `packages.x86_64`, ISO build/validation scripts | Source-only | UNVERIFIED | UNVERIFIED | UNVERIFIED | UNVERIFIED | Normal product path is Plasma Wayland Live. Must prove desktop survives Installer close/crash and remains usable for diagnostics/recovery | **P0 (Open)** |
| **Cage Kiosk / Fallback** | Yes as fallback | `installer/bin/meoarch-installer-kiosk` and staged Live assets | Source-tested historically | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Optional kiosk/fallback only; must not be treated as the normal Live UX | **P1 (Fallback)** |
| **Installer Host (QML/C++)** | Yes | `installer/app/main.cpp` and installer runtime | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | GUI lifetime must not own/kill destructive installation work | **P0 (Open)** |
| **Live environment / target desktop split** | Partial | Live-session staging, target customization, package plan | Source-only | UNVERIFIED | UNVERIFIED | UNVERIFIED | UNVERIFIED | Live state and installed-target state must remain separate; Plasma Live is not evidence that target first login works | **P0 (Open)** |
| **Privilege Boundary** | Partial | Installer backend/service boundaries and Polkit/system-service contracts | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Read-only `org.meo.SystemTransaction1` foundation exists; destructive/install writers still require runtime authorization/rollback proof | **P0 (Open)** |
| **Network Management** | Yes in source | `installer/backend/hardware.py` / NetworkManager | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Must prove secrets are not leaked and reconnect/error states work in real Live session | **P0 (Verify)** |
| **Storage & Enumeration** | Yes in source | `installer/backend/hardware.py` | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Uses stable device identity where available; must prove Live medium protection on real candidate | **P0 (Verify)** |
| **Partitioning (Erase Disk)** | Yes in source | `installer/backend/generate-config.py` | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Destructive path requires repeated VM install/reboot proof | **P0 (Open)** |
| **Encryption (LUKS)** | **No — blocked by current generator** | `installer/backend/generate-config.py` (`diskEncryption` rejection) and regression test | Source rejection tested | No | No | UNVERIFIED | No | Passphrase lifecycle, Archinstall configuration, recovery and UEFI VM proof are still required | **P0 (Blocked when encryption is a release requirement)** |
| **Account & Security / target login** | Partial | `generate-config.py`, `apply-target-customizations.sh`, login-manager integration | Source-only | UNVERIFIED | UNVERIFIED | UNVERIFIED | UNVERIFIED | Automatic login is not the target. Must prove created user, privileges, login manager, authentication and first session together | **P0 (Open)** |
| **Locale & Timezone** | Yes in source | `generate-config.py` | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Must verify target readback after reboot | **P0 (Verify)** |
| **Hardware Detection** | Yes in source | `installer/backend/hardware.py` | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Driver plan still needs representative real-hardware evidence | **P0/P1 (Verify)** |
| **Base Packages** | Yes | `meoarch-os/packages.x86_64` and resolved repositories | Source-resolved | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Package presence is not proof of working session integration | **P0 (Verify)** |
| **Archinstall Integration** | Yes in source | `run-archinstall.sh` and generated plan/config | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | GUI/CLI must converge on one `InstallConfig -> InstallPlan -> runner` path and survive GUI exit | **P0 (Open)** |
| **MeoUI Runtime** | Yes in source | `projects/meo-ui` / packaged runtime | Source-tested | UNVERIFIED installed candidate | UNVERIFIED installed candidate | UNVERIFIED | UNVERIFIED | UI library success does not prove full system/session integration | **P0/P1 (Verify)** |
| **Meo.System / shared backend** | Partial | Meo system adapters plus shared service contracts | Source-tested by component | UNVERIFIED as one installed authority | UNVERIFIED | UNVERIFIED | UNVERIFIED | Network/audio/display/power/telemetry still need one maintained typed authority instead of duplicated adapters | **P0 (Open)** |
| **Meo Desktop Payload** | Yes in source | `meo-kde` look-and-feel / shell/session integration | Source-tested | UNVERIFIED installed candidate | UNVERIFIED installed candidate | UNVERIFIED | UNVERIFIED | Default Meo Desktop is Plasma 6 Wayland + KWin; KScreenLocker remains its lock authority | **P0 (Verify)** |
| **OmniStore Provisioning** | Partial | OmniStore provisioning/package contracts | Source-tested by component | UNVERIFIED installed candidate | UNVERIFIED | UNVERIFIED | UNVERIFIED | Installed-system package/channel flow must use signed repositories and canonical catalog metadata | **P1 (Open)** |
| **Target OS Validation** | Yes in source | `scripts/verify-target-install.sh` | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Chroot/static validation cannot replace reboot + first-login acceptance | **P0 (Open)** |
| **ISO Generation** | Yes in source | `scripts/build-iso.sh`, `meoarch-os/profiledef.sh` | Source-tested | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | A successful build is not a boot/install acceptance result | **P0 (Verify)** |
| **UEFI Boot** | Configured | `meoarch-os/profiledef.sh` (`uefi.grub`) + GRUB assets | Source-configured | UNVERIFIED current candidate | UNVERIFIED current candidate | UNVERIFIED | UNVERIFIED | Must validate the current GRUB path on OVMF and at least representative hardware | **P0 (Open)** |

## Evidence rule

When updating this matrix, record the strongest evidence layer actually observed:

```text
source/static
  < package/build
  < ISO boot
  < install in VM
  < reboot + first login
  < repeated failure/recovery testing
  < representative real hardware
```

Do not copy an older `Yes` forward merely because the source file still exists. A row may be implemented in source while remaining release-blocking because the current candidate has not been exercised at the required runtime layer.
