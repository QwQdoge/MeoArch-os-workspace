# Production installer architecture

The MeoArch installer has two intentionally separate execution modes.

- `meoarch-installer` is a non-destructive development entrypoint. It cannot
  enable installation or power actions on its own.
- `meoarch-installer-kiosk` is the ISO-owned Cage entrypoint. It supplies
  `--production --enable-real-install --enable-system-actions`.
- `--preview` selects `PreviewController` for screenshot and visual-regression
  work. It is rejected when combined with `--production`.

## UI and shared runtime boundaries

`installer/qml/` owns MeoArch branding and wizard business flow. It imports
`MeoUI 1.0` for visual primitives and imports `Meo.System 1.0` for the network
page. The page therefore uses the existing NetworkManagerQt-backed
`SystemState` API for Ethernet/Wi-Fi status, wireless enablement, scans,
saved-network activation, WPA/WPA2, WPA3-SAE, open networks, connect, and
disconnect. The installer does not keep a second Wi-Fi backend or a hard-coded
network list.

The ISO synchronization script builds and stages the current local Meo.System
runtime from the sibling Meo KDE source together with MeoUI. It does not edit
either sibling working tree.

## Installation plan and secrets

The native controller persists only non-secret selections to
`/tmp/meoarch-installer/selections.json`. Account password hashing is started
asynchronously; its hash is written into a temporary mode-0600 credentials
file solely for configuration generation, then removed. Plaintext account,
Wi-Fi, and disk-encryption passwords are not placed in selections, summaries,
or diagnostics.

`prepareInstallation()` is the only path into a ready plan:

1. persist non-secret selections;
2. generate Archinstall JSON and target customizations asynchronously;
3. run the Archinstall dry-run helper asynchronously;
4. enable destructive confirmation only when the helper reports `complete`.

The Archinstall adapter requires both the ready manifest and the successful
preflight result. It emits structured, monotonic JSONL stage events and removes
the credentials file on every exit path.

## Disk safety

Disk enumeration is asynchronous `lsblk` JSON parsing. Production mode never
adds preview disks. It records stable `/dev/disk/by-id` identity where
available, model, serial, WWN, transport, and capacity. Removable, mounted, and
running-media disks are ineligible for erase install.

Only the tested erase-disk plan is enabled at present: GPT, a 1 GiB EFI system
partition, and Btrfs or ext4 root. Manual partitioning is explicitly
unavailable until it can produce and validate the current Archinstall disk
schema. Disk encryption is likewise unavailable: no passphrase is collected
until a reviewed Archinstall credential/cleanup path exists.

Swap choices are real: Archinstall configures zram; the target customizations
create an idempotent 4 GiB swap file only when selected; `none` creates neither.

## Target customizations and validation

Target-side customization applies the user GECOS name, optional SDDM Plasma
autologin (`plasma.desktop`), optional `firewalld` package/service, swap-file
setup, MeoUI, and Meo Desktop defaults. Final validation checks target
`os-release`, `fstab`, and the MeoUI QML runtime before reporting success.

The Apps page is intentionally unavailable until an OmniStore runtime and a
tested first-login provisioning consumer are packaged into the target. The
installer does not write an orphaned provisioning intent.

## Translation and validation

QML uses `qsTr()` for newly changed UI and the native application reloads a Qt
Linguist catalog whenever the global language action changes. English is the
fallback; the current catalog provides Simplified Chinese translations and is
staged as `translations/meoarch_zh_CN.qm` in the ISO.

Repository checks cover generator validation, secret exclusion, hardware
planning, shell syntax, QML lint, native installer build, Meo.System build, and
explicit preview screenshots. A full destructive claim still requires the
separate UEFI VM acceptance flow; never use a host disk for that test.
