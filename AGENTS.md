# MeoArch OS Workspace agent rules

## Canonical repository and ownership

This is the canonical public ISO/integration repository. Do not use the deprecated underscore repository `QwQdoge/MeoArch_os-workspace` for new work.

- `installer/`: graphical installer source, backend, tests, and installer-specific data.
- `repair/`: repair app, checks/actions, tests, and knowledge.
- `meoarch-os/`: authoritative ArchISO profile and boot/package inputs.
- `scripts/`: maintained staging/build/acceptance entrypoints.
- Shared QML/tokens belong in MeoUI via `$MEO_UI_ROOT`; Plasma/Meo.System integration belongs in meo-kde via `$MEO_KDE_ROOT`.

Do not copy sibling repositories into this worktree or edit staged duplicates as source authority.

## Work sequence

1. Inspect `git status`, the owning source, and only the directly relevant contract.
2. Make the smallest source-owned change.
3. If installer source must enter the ISO tree, stage only with `scripts/sync-installer-to-airootfs.sh`.
4. Run source/static checks first; build components/ISO only when the task needs that evidence.

## Validation

For normal installer/repair changes, mirror source CI:
- `python -m compileall -q installer repair`
- `python -m unittest discover -s installer/tests -p 'test_*.py' -v`
- `python -m unittest discover -s repair/tests -p 'test_*.py' -v`
- `bash -n` affected shell entrypoints

For compiled runtime changes, use `scripts/acceptance/20-build-components.sh`. ISO build/inspection, Live boot, and installed-system boot are progressively stronger and separate evidence levels; none implies the next.

The current UEFI path is GRUB (`profiledef.sh`), not the removed systemd-boot entry set. Do not restore old boot assets merely because they exist in repository history.

## Files and safety

Use `$MEO_DOCS_ROOT/Projects/meo-arch-os-workspace/` for plans/audits/decisions and `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/{build,install,validation,packages,tmp}/` for new generated output. Existing script-managed legacy build/artifact material is retained.

Do not publish an ISO, write a disk, alter a live device, modify a remote release, or run destructive deployment/recovery actions without explicit authorization. Preserve dirty work; avoid reset/clean/broad deletion.
