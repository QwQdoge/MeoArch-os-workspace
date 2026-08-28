# MeoArch OS Installer Specification

## Overview

The MeoArch OS Installer is a fullscreen graphical installer designed for the
MeoArch live ISO. It runs as a focused kiosk application instead of exposing a
traditional desktop session first.

The first implementation target is a safe, non-destructive framework. It can
present the installation flow, collect future choices, and generate an
`archinstall` configuration preview. It must not partition disks, format
filesystems, mount target disks, or run a real installation until the destructive
path is explicitly designed and reviewed.

## Product Goals

The installer should feel calm, clear, and trustworthy. It should guide normal
users through the installation without exposing technical Linux details unless
they choose an Advanced path.

Primary goals:

- Provide a simple graphical installation experience for MeoArch OS.
- Make destructive choices obvious before they happen.
- Keep privacy and security visible as product features.
- Use `archinstall` as the future installation backend, driven by validated
  structured configuration rather than ad-hoc shell commands.
- Keep technical details available for advanced users without making them part
  of the default flow.

Non-goals for the first framework:

- Real disk partitioning
- Filesystem formatting
- Mounting target disks for installation
- Running `archinstall`
- Installing GRUB
- Creating real target users
- Modifying firmware boot entries

## System Baseline

Current assumptions:

- Base distribution: Arch Linux
- ISO builder: archiso
- Kiosk compositor: Cage
- Installer UI: Qt Quick/QML
- Future backend: `archinstall`
- Default bootloader target: GRUB
- Default target desktop: MeoArch-customized KDE Plasma
- Current framework behavior: safe preview only

These assumptions can evolve, but any change that affects disk operations,
bootloader behavior, or the final installed system should be documented before
implementation.

## Runtime Architecture

The live ISO starts a single graphical installer inside Cage:

```text
Live ISO boot
  -> systemd
  -> meoarch-installer.service
  -> meoarch-installer-kiosk
  -> cage
  -> meoarch-installer
  -> QML installer UI
```

The installer currently writes only a preview file:

```text
/tmp/meoarch-archinstall-preview.json
```

That preview represents the future shape of the `archinstall` configuration, but
it is not executed by the framework.

## User Experience Principles

The default flow is for regular users. Advanced Linux concepts must be hidden
unless the user asks for them.

Use plain language:

- Say `512 GB SSD`, not `/dev/nvme0n1`.
- Say `Erase disk and install`, not `create GPT, EFI, root, swap`.
- Say `Recommended privacy settings are enabled`, not `nftables service active`.

Every destructive step must have:

- A simple explanation
- A visible warning
- A summary before execution
- A final confirmation before changes become irreversible

## Installer Flow

Recommended flow:

```text
Welcome
Language & Region
Keyboard Layout
Network
Privacy & Security
Disk Selection
User Account
Summary
Installing
Finish
```

The current framework may contain placeholder pages while implementation is in
progress, but the final user-facing flow should follow this order.

## Page Specifications

### 1. Welcome

Visibility: required.

Purpose: introduce the system and start the installation.

Show:

- System name
- Logo
- Short introduction
- Language selector
- `Start Installation` button

Suggested copy:

```text
Welcome to MeoArch OS Installer
This installer will help you install the system safely and simply.
```

Do not show:

- Partition details
- Bootloader options
- Swap settings
- Filesystem choices
- Kernel parameters

### 2. Language & Region

Visibility: required or strongly recommended.

Purpose: choose user-facing language, region, and time zone.

Show:

- Language: English / Chinese / Japanese
- Region: Singapore / China / Japan / etc.
- Time zone: automatically detected, editable by the user

Do not show:

- Locale codes such as `en_US.UTF-8`
- `/etc/locale.gen`
- NTP details

### 3. Keyboard Layout

Visibility: required or strongly recommended.

Purpose: prevent password entry problems caused by the wrong keyboard layout.

Show:

- Keyboard layout: US / UK / Chinese / Japanese
- Test input: `Type here to test your keyboard`

Do not show:

- XKB model
- Variant
- Compose key

Those belong in Advanced settings.

### 4. Network

Visibility: conditional.

If the system is already online, keep the page minimal:

```text
Connected to the Internet
```

If offline, show connection options.

Show:

- Current network status
- Wi-Fi list when supported
- Wired network status
- `Retry` and `Skip`

Do not show by default:

- IP address
- DNS
- Gateway
- Proxy

Those belong in Advanced settings.

### 5. Privacy & Security

Visibility: required.

Purpose: make MeoArch's privacy and security posture visible and understandable.

Show:

- Recommended privacy settings enabled by default
- Disable telemetry
- Enable firewall
- Enable automatic security updates
- Encrypt disk
- Restrict default permissions

Suggested copy:

```text
Recommended privacy settings are enabled by default.
[x] Disable telemetry
[x] Enable firewall
[x] Enable automatic security updates
[ ] Encrypt disk
```

Do not show:

- `iptables` or `nftables` rules
- Encryption algorithm details
- systemd service details

### 6. Disk Selection

Visibility: required.

Purpose: choose the installation target. This is the highest-risk page because
it can lead to data loss.

Default mode:

```text
Choose where to install the system
```

Show:

- Disk name
- Disk size
- Whether data will be erased
- Warning: `This will erase all data on the selected disk.`

Default choices:

- `Erase disk and install`
- `Custom full-disk layout / Advanced`

Do not show by default:

- `/dev/sda`
- `/dev/nvme0n1p1`
- EFI partition
- Root partition
- Swap partition
- `ext4` or `btrfs`

Those belong in Advanced settings.

### 7. User Account

Visibility: required.

Purpose: create the account used after installation.

Show:

- Your name
- Username
- Computer name
- Password
- Confirm password
- Automatic login option

Do not show:

- UID
- Shell
- `sudo` group
- Home directory path

Defaults should handle those values.

### 8. Summary

Visibility: required.

Purpose: final safety checkpoint before destructive changes.

Show:

```text
Ready to install

Language: English
Keyboard: US
Disk: 512 GB SSD
Install mode: Erase disk
Privacy: Recommended settings enabled
User: shekong
```

Buttons:

```text
Back        Install Now
```

Warning:

```text
After clicking Install Now, disk changes cannot be undone.
```

Advanced users may open `Show details` to inspect technical output.

### 9. Installing

Visibility: required.

Purpose: show progress while the backend performs installation steps.

Show:

- Progress bar
- Current step
- Short explanation
- Expandable log

Example steps:

```text
Installing system files...
Setting up user account...
Installing bootloader...
Applying privacy settings...
```

Do not show full logs by default. Use `Show details`.

### 10. Finish

Visibility: required.

Purpose: give the user a clear end state.

Show:

```text
Installation complete
You can now restart your computer.
```

Buttons:

- `Restart Now`

Optional:

- `Remove installation media after shutdown`

Do not show complex logs, stack traces, or install paths unless installation
failed.

## Visibility Matrix

| Module | Visibility | Reason |
| --- | --- | --- |
| Welcome | Required | Establish installer identity |
| Language | Required / recommended | Normal users need it |
| Region / time zone | Recommended | Can be auto-detected |
| Keyboard layout | Required / recommended | Password input must be reliable |
| Network | Conditional | Keep weak if already connected |
| Privacy settings | Required | Matches project focus |
| Disk selection | Required | High-risk operation |
| Custom full-disk layout | Advanced only | Adjusts root and separate home without leaving Cage |
| User account | Required | Needed for login after install |
| Bootloader | Hidden by default | Too technical |
| Filesystem choice | Hidden by default | Too technical |
| Swap settings | Hidden by default | Should be automatic |
| Summary | Required | Prevent mistaken installs |
| Install logs | Hidden by default | Show only on request |
| Finish | Required | Gives a clear end state |

## Backend Boundaries

The UI may:

- Display structured state
- Navigate pages
- Collect user choices
- Request detection or preview generation
- Show progress and logs

The UI must not:

- Parse raw command output from tools such as `lsblk`
- Build shell commands from user-visible labels
- Partition disks
- Format filesystems
- Mount installation targets
- Execute installation commands directly

The backend should:

- Read hardware and disk information
- Normalize data into versioned JSON
- Validate user choices
- Generate an `archinstall` configuration
- Keep dry-run and real execution paths separate

## Future `archinstall` Configuration

The installer should eventually generate a validated configuration similar to:

```json
{
  "hostname": "meoarch",
  "locale_config": {
    "kb_layout": "us",
    "sys_enc": "UTF-8",
    "sys_lang": "en_US"
  },
  "mirror_config": {
    "mirror_regions": {
      "Worldwide": ["https://geo.mirror.pkgbuild.com/$repo/os/$arch"]
    }
  },
  "timezone": "UTC"
}
```

This schema must be expanded only after the corresponding UI validation exists.

## First-Phase Safety Rules

Allowed in the framework phase:

- Read hardware information
- Read disk information
- Detect network state
- Generate a preview configuration
- Write temporary installer logs

Forbidden in the framework phase:

- Modify partition tables
- Format filesystems
- Mount target disks for installation
- Run `archinstall`
- Run `pacstrap`
- Generate or overwrite a real `fstab`
- Run `grub-install`
- Create target-system users
- Modify firmware boot entries

## Open Decisions

These topics require separate design before implementation:

- Automatic partition layout
- Default filesystem
- Full-disk encryption behavior
- Dual-boot strategy
- Exact KDE Plasma package set
- MeoArch-owned package list
- GRUB parameters for BIOS and UEFI
- Secure Boot support
- Offline installation behavior
- Failure recovery and rollback behavior
