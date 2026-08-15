# VM Testing

The acceptance baseline is x86_64, OVMF UEFI, 4 vCPU, 8 GiB RAM, a 64 GiB
qcow2-backed virtual NVMe disk with a fixed serial, user-mode NAT and a virtio
virtual GPU. KVM is used when available;
QEMU TCG is the fallback.

Create a disposable disk below the test-run artifacts directory:

```bash
export MEOARCH_RUN_DIR="$PWD/artifacts/validation/test-runs/manual"
./scripts/acceptance/50-create-vm.sh
```

Boot a generated ISO:

```bash
./scripts/acceptance/60-boot-live.sh \
  "$PWD/artifacts/releases/candidates/meoarch-os-YYYY.MM.DD-x86_64.iso" \
  "$MEOARCH_RUN_DIR/vm/meoarch-test.qcow2"
```

The script rejects `/dev/*` targets and disks outside the repository-controlled
`artifacts` directory. It creates a writable copy of OVMF variables and records
the exact VM configuration and serial console output.

For automated acceptance, set `MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY` while building
the ISO. The build copies that public key only into its staged profile; it does
not alter the source ArchISO profile. Guest SSH is forwarded to
`127.0.0.1:2222`.

Capture each visible Installer checkpoint through QMP. The helper numbers the
PNG files and stores them inside the active run directory:

```bash
./scripts/acceptance/65-capture-step.sh 01-language
./scripts/acceptance/65-capture-step.sh 02-network
./scripts/acceptance/65-capture-step.sh 03-disk
```

For installation, select only the 64 GiB QEMU NVMe disk. After a clean
shutdown, boot the same disk without the ISO and record proof that the installed
root and bootloader are used. Do not inspect a disk read-write while QEMU is
running.

Store screenshots, installer logs, package logs, partition/fstab output,
first-login observations and performance measurements below the same run
directory. A visible Live ISO is not evidence of an installed-system boot.
