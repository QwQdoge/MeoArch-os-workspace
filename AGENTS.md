# MeoArch Workspace Guidance

This repository assembles the MeoArch ISO. Read this file before creating,
moving, or validating project material.

## Source ownership

- Shared QML design tokens and generic motion/components belong in
  `$HOME/Projects/meo-ui`.
- KDE/Plasma-specific integration and `Meo.System` belong in
  `$HOME/Projects/meo-kde`.
- ISO staging, the installer, Archinstall integration, and release validation
  belong in this workspace.
- Do not copy sibling-project historical evidence into this repository.

## Where generated material goes

All MeoArch-generated output is Git-ignored and must stay below `artifacts/`:

| Material | Required path |
| --- | --- |
| Candidate or release ISO | `artifacts/releases/iso/` or `artifacts/releases/candidates/` |
| ISO build log, checksum, staging provenance | `artifacts/logs/iso/<UTC timestamp>/` |
| Installer screenshots | `artifacts/screenshots/installer/<capture-name>/` |
| VM disks, ISO extracts, test evidence | `artifacts/validation/test-runs/<run-id>/` |
| Historical validation evidence | `artifacts/validation/<release-id>/` |
| Recovery/provenance snapshots | `artifacts/provenance/<run-id>/` |

Use `build/` only for reproducible compiler and ArchISO work space. Do not put
release images, screenshots, or validation evidence in `build/`, the project
root, or `$HOME/Projects/outputs`.

`scripts/build-iso.sh` defaults to `artifacts/releases/iso/` and
`artifacts/logs/iso/`; retain those defaults unless a task explicitly requests
an isolated output location.

## Safety

- Preserve unrelated dirty work and never reset, delete, or overwrite it.
- A live ISO or static check is not proof of an installed-system boot.
- Use `scripts/sync-installer-to-airootfs.sh` for ISO staging; do not scatter
  manual copies into `meoarch-os/airootfs`.
