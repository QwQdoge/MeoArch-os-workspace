# VM Testing

The acceptance baseline is x86_64, OVMF UEFI, 4 vCPU, 8 GiB RAM, a 64 GiB
qcow2-backed virtual NVMe disk with a fixed serial, user-mode NAT and a virtio
virtual GPU. KVM is used when available;
QEMU TCG is the fallback.

## Run layout

Create one explicit UTC run identifier in the global MeoArch output tree. The
default layout keeps retained evidence separate from disposable VM state:

```bash
run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-manual-vm"
export MEOARCH_OUTPUT_ROOT="$HOME/Projects/outputs/meo-arch-os-workspace"
export MEOARCH_RUN_ID="${run_id}"
export MEOARCH_RUN_DIR="${MEOARCH_OUTPUT_ROOT}/validation/${run_id}"
export MEOARCH_TMP_DIR="${MEOARCH_OUTPUT_ROOT}/tmp/${run_id}"
```

- `validation/<run-id>/` retains logs, status files, hashes, VM configuration,
  serial logs, and installer screenshots.
- `packages/iso/<run-id>/` holds the candidate ISO. The ISO build stage records
  its exact path in `validation/<run-id>/iso/iso-path.txt`.
- `tmp/<run-id>/` holds the disposable qcow2 disk, writable OVMF variables,
  QMP sockets, unpacked ISO data, and screenshot intermediates.
- `install/<run-id>/` is used only when a bootable VM must be handed to another
  operator; enable that deliberately with `MEOARCH_VM_HANDOFF=1` before the
  disk is created.

`MEOARCH_RUN_DIR`, `MEOARCH_TMP_DIR`, `MEOARCH_ISO_OUTPUT_DIR`,
`MEOARCH_INSTALL_DIR`, and `MEOARCH_QEMU_SOCKET_DIR` remain explicit overrides;
an explicit path always takes precedence over the defaults.

## Create and boot a disposable VM

Create a disposable disk:

```bash
./scripts/acceptance/50-create-vm.sh
```

Build an ISO in the matching package run, then boot it. The live-boot helper
uses the recorded ISO and disk paths when arguments are omitted:

```bash
./scripts/acceptance/30-build-iso.sh
./scripts/acceptance/60-boot-live.sh
```

The disk creator rejects `/dev/*` and paths outside the designated VM directory.
It creates a writable OVMF copy in the disposable VM directory and records the
exact VM configuration and serial console output in the validation directory.

For automated acceptance, set `MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY` only with an
explicit `--acceptance` build (the acceptance wrapper already supplies it). The
build copies that public key only into its staged profile and writes the ISO to
the isolated `packages/iso/acceptance/` namespace; it does not alter the source
ArchISO profile. A normal build refuses that environment variable. Guest SSH is
forwarded to `127.0.0.1:2222`.

Capture each visible Installer checkpoint through QMP. The helper numbers the
PNG files in the active validation run while keeping the temporary PPM files in
the matching `tmp/` run:

```bash
./scripts/acceptance/65-capture-step.sh 01-language
./scripts/acceptance/65-capture-step.sh 02-network
./scripts/acceptance/65-capture-step.sh 03-disk
```

For installation, select only the 64 GiB QEMU NVMe disk. After a clean
shutdown, boot the same disk without the ISO and record proof that the installed
root and bootloader are used. Do not inspect a disk read-write while QEMU is
running.

To retain a bootable disk for handoff instead of treating it as disposable, set
the flag before creating it, then use the same run variables for live and
installed boots:

```bash
export MEOARCH_VM_HANDOFF=1
./scripts/acceptance/50-create-vm.sh
./scripts/acceptance/60-boot-live.sh
# Complete installation in the controlled VM, shut it down, then:
./scripts/acceptance/70-boot-installed.sh
```

Store screenshots, installer logs, package logs, partition/fstab output,
first-login observations and performance measurements under the matching
`validation/<run-id>/` directory. A visible Live ISO is not evidence of an
installed-system boot.

## Testing unpublished candidate packages

When the target must exercise locally built, unpublished packages, pass a
directory under the global output root as a read-only 9p share to the installed
VM. Inside the guest it can be mounted without exposing host credentials or
host audio:

```bash
export MEOARCH_QEMU_SHARE="${MEOARCH_OUTPUT_ROOT}/packages/candidates"
export MEOARCH_VM_AUDIO=1
./scripts/acceptance/70-boot-installed.sh
# guest: mount -t 9p -o ro,trans=virtio,version=9p2000.L meo-candidates /mnt/meo-candidates
```

`MEOARCH_VM_AUDIO=1` creates only a discard-only virtual HDA output. It is
appropriate for checking PipeWire/PulseAudio device discovery and the lock
screen's volume/mute controls; it does not route guest sound to the host.
