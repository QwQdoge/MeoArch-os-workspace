# MeoArch OS Workspace agent rules

This repository is the ISO integration worktree. Make the smallest
source-owned change that satisfies the task, and preserve the ISO profile,
existing worktrees, package inputs, builds, and historical material.

## Ownership

- Shared QML components, tokens, and reusable showcase behavior belong in
  $HOME/Projects/meo-ui.
- Plasma/KWin-specific integration and Meo.System belong in
  $HOME/Projects/meo-kde.
- ArchISO assembly, installer code, repair tooling, and ISO staging belong
  here.
- Do not copy a sibling project into this worktree or create an untracked
  replacement of a sibling component.

## Repository filing rules

- Keep source, tests, assets, and tool configuration in their existing owning
  directories.
- Put code-bound design, deployment, build, and operating contracts in docs/
  or the component documentation directory that already owns them.
- Do not create root-level plan files, audit reports, architecture drafts,
  agent journals, screenshots, logs, or one-off notes.
- Put plans, decisions, audit reports, work journals, and historical evidence
  under $HOME/Documents/Obsidian Vault/MeoArch/Projects/meo-arch-os-workspace/.
  Use its numbered folders: 00-inbox, 01-overview, 02-decisions, 03-work,
  04-validation, and 99-archive.

## Output rules

New durable output belongs only under
$HOME/Projects/outputs/meo-arch-os-workspace/:

| Kind | Path |
| --- | --- |
| Reproducible build work | build/ |
| Install or VM handoff | install/ |
| Validation evidence | validation/<UTC-run-id>/ |
| ISO/package deliverables | packages/ |
| Disposable work | tmp/ |

Use a UTC run identifier in the form YYYY-MM-DDTHHMMSSZ-short-label. Existing
script-managed build/ and artifacts/ material is retained; do not move it,
delete it, or change scripts solely to enforce this filing rule.

## ISO integrity and validation

- Keep meoarch-os/ as the source ArchISO profile. Do not delete, rename, or
  replace it with a copied profile.
- Stage installer changes only with scripts/sync-installer-to-airootfs.sh.
  Manual airootfs copying produces unverifiable state.
- Keep package lists, boot configuration, versioned assets, and ISO package
  sources intact. Do not use git reset, git clean, blanket deletion, or an
  unreviewed recursive command to tidy them.
- Distinguish source validation, staging provenance, live-ISO boot, and
  installed-system acceptance in the validation record. None implies the next.

## Authorization boundary

Do not publish an ISO, alter a live device, write a disk, modify a remote
release, or run destructive deployment/recovery commands unless the user has
explicitly authorized that exact action. Preserve dirty work and report it
rather than overwriting it.
