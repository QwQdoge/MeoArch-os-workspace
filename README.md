# MeoArch OS Workspace

This is the MeoArch ISO integration worktree. It owns the ArchISO profile,
installer, repair tool, ISO-facing configuration, branding assets, and the
scripts that assemble and validate a candidate image. Shared UI primitives do
not belong here: reusable QML belongs in the sibling MeoUI project, while
Plasma-specific integration belongs in MeoKDE.


## Install Meo Desktop on an existing Arch system

The public MeoArch workspace is the unified remote entry point. To start the
guided installer:

```bash
curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash
```

The bootstrap itself only downloads MeoKDE and MeoUI snapshots into
`~/.cache/meo-installer/components/` and then hands control to MeoKDE's
versioned installer. Package installation, sudo use, system services, Plasma
layout changes, and system-wide responsiveness settings remain explicit choices
inside that installer.

Recommended full setup:

```bash
curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash -s -- --full
```

For a machine with multiple desktop environments, install the full Meo KDE
experience without applying system-wide zram / scheduler / power-profile /
GameMode policy:

```bash
curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash -s -- --full --kde-only
```


## What is in this repository

| Path | Purpose |
| --- | --- |
| meoarch-os/ | The retained ArchISO profile, including airootfs, boot configuration, and package lists. |
| installer/ | Installer application source, QML, backend code, tests, translations, and installer-specific documentation. |
| repair/ | MeoArch repair application source and repair checks/actions. |
| themes/ | ISO-owned theme staging/configuration and its local documentation. |
| assets/ | Versioned fonts, icons, logos, and wallpapers used by the ISO. |
| configs/ | ISO/system configuration inputs. |
| scripts/ | Build, staging, kiosk, and acceptance entry points. |
| docs/ | Code- and operations-bound documentation for the installer and ISO workflow. |

The root README and AGENTS files are orientation and operating rules. Root-level
configuration files and source-owned build metadata remain where their tools
require them. Do not add ad-hoc reports, screenshots, plans, or architecture
notes to the root.

## Working with the ISO

Edit the authoritative source first, then use the maintained workflow:

1. Change installer code under installer/, ISO inputs under meoarch-os/, or
   ISO-owned assets/configuration in their existing folders.
2. Use scripts/sync-installer-to-airootfs.sh for installer staging; do not
   scatter manual copies into airootfs.
3. Use the build and acceptance scripts only when the task authorizes a build
   or test. A source/static result, a staged ISO, a live-ISO boot, and an
   installed-system boot are separate levels of evidence.

The existing build/ and artifacts/ directories are retained because current
tools use them. They are not places for new hand-written evidence or scratch
documents. Do not rewrite scripts merely to reorganize their existing outputs.

## Filing rule for new material

Use the following locations for all new material. This rule prevents the
repository root from becoming a notebook or a download folder.

| Material | Required location |
| --- | --- |
| Source, tests, or versioned assets | Their existing owning source directory in this repository. |
| A contract tied to code or an operator workflow | docs/ or the code component's existing documentation directory. |
| Plans, audits, decisions, agent journals, meeting notes, and historical reports | `$MEO_DOCS_ROOT/Projects/meo-arch-os-workspace/` |
| Reproducible build work | `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/build/` |
| Install/VM handoff material | `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/install/` |
| Validation evidence | `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/validation/<UTC-run-id>/` |
| Candidate ISOs and package-like deliverables | `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/packages/` |
| Disposable generated work | `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/tmp/` |

Use a UTC run identifier in the form YYYY-MM-DDTHHMMSSZ-short-label, such as
2026-08-26T143015Z-installer-smoke, for every
validation directory. In the project documentation folder, file incoming
material in 00-inbox, overview material in 01-overview, decisions in
02-decisions, work notes in 03-work, validation summaries in 04-validation, and
superseded records in 99-archive.

Existing root documents, artifacts, builds, ISO workspaces, and historical
files are deliberately retained by this organization pass. Do not delete,
rename, or move them as routine cleanup. A future migration needs its own
reviewed task and a recovery plan.

## Safety and release boundary

- Never delete or rename meoarch-os/, installer/, repair/, versioned ISO assets,
  package lists, or a checked-out worktree to make the tree look cleaner.
- Do not run a destructive clean, publish an ISO, modify a live system, or
  deploy any component without explicit authorization.
- Do not treat a generated ISO, screenshot, log, or static check as proof of a
  successful installation. Record the exact level of validation in the project
  documentation.
- Keep credentials, user data, disk images containing user data, and secrets
  out of source control and shared evidence folders.

## Licensing

Original MeoArch code and configuration in this repository are licensed under
the MIT License; see `LICENSE`. Portions of the `meoarch-os/` ArchISO profile
that are derived from ArchISO remain under GPL-3.0-or-later; see
`LICENSES/GPL-3.0-or-later.txt`. Vendored third-party material remains under
its upstream license; see `THIRD_PARTY_NOTICES.md` and
`docs/third-party-software.md`.

For detailed build, installer, and release contracts, use the documents already
under docs/ and installer/.
