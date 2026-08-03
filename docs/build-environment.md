# Build Environment

Verified on 2026-07-31 (Asia/Singapore).

## Host

- Distribution: CachyOS (Arch family)
- Architecture: x86_64
- Kernel: 7.1.5-1-cachyos
- Hardware virtualization: CPU virtualization flag present
- KVM: `/dev/kvm` exists and is readable/writable by the current user
- Passwordless root: unavailable
- Unprivileged user namespaces: available

ArchISO 89 supports an unprivileged build path through `pacstrap -N` and user
namespaces, so passwordless `sudo` is not required on this host.

## Available tools

- archiso / mkarchiso: 89
- QEMU desktop/system x86: 11.0.2
- OVMF: 202605 (`/usr/share/edk2/x64/OVMF_CODE.4m.fd`)
- CMake: 4.4.1
- Ninja: 1.13.2
- Qt: 6.11.1
- Plasma workspace: 6.7.3
- systemd-nspawn, xorriso, bsdtar, mksquashfs, readelf and objdump

## Unavailable or optional

- `virt-install`: unavailable; the acceptance scripts invoke QEMU directly.
- `qmllint6` and `qmltestrunner6`: not exposed as commands by the host Qt
  package. QML is compiled by CMake's Qt QML pipeline instead.
- Podman: unavailable.
- Docker CLI is present, but the Docker daemon is not running. Docker is not a
  build dependency.

Run `scripts/acceptance/00-environment.sh` to refresh the machine-readable
evidence for a test run.
