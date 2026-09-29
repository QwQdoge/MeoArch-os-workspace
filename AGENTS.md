# MeoArch OS Workspace agent rules

## Canonical repository

This is the active/canonical MeoArch OS ISO integration repository. The legacy `QwQdoge/MeoArch_os-workspace` repository is deprecated and must not be used for new work.

Inspect `git status`, the affected component, and its nearest tests/contracts first. Do not read every document or build the whole ISO unless the task requires it.

## Ownership and cross-repository boundaries

- `installer/`: installer app, backend, tests, translations, and live Meo.System bridge.
- `repair/`: Quick Repair source, checks/actions, privileged service, knowledge, and tests.
- `meoarch-os/`: authoritative ArchISO profile, package list, boot config, and airootfs inputs.
- `scripts/`: staging, build, acceptance, bootstrap, and verification entry points.
- `assets/`, `configs/`, `themes/`: ISO-owned versioned inputs.
- Generic reusable QML/tokens/motion belong in MeoUI via `$MEO_UI_ROOT`.
- Plasma/KWin/Meo.System desktop integration belongs in meo-kde via `$MEO_KDE_ROOT`.
- Do not copy sibling repositories into this worktree or treat staged airootfs files as source authority.

## Validation ladder

Use the lowest sufficient level first; each level proves only itself.

1. **Source/static**
   - `python -m compileall -q installer repair`
   - `python -m unittest discover -s installer/tests -p 'test_*.py' -v`
   - `python -m unittest discover -s repair/tests -p 'test_*.py' -v`
   - `bash -n` only the affected shell entry points.
2. **Component/runtime integration**
   For C++/QML/native installer or repair integration changes, mirror `.github/workflows/component-build.yml` or run `scripts/acceptance/20-build-components.sh` with valid MeoUI/meo-kde sibling sources.
3. **Staging**
   Stage installer changes only through `scripts/sync-installer-to-airootfs.sh`; then use the existing staging provenance verifier when staging behavior changed.
4. **ISO**
   Build/inspect an ISO only when the task needs ISO-level evidence.
5. **VM/live/installed system**
   Run live boot or installed-system acceptance only when explicitly requested/authorized and the environment supports it.

Never describe source tests, staging, an ISO build, a live boot, or an installed boot as proving the next level.

## ISO integrity

Keep `meoarch-os/` as the source profile. Preserve package lists, boot configuration, licensing, versioned assets, and source provenance. Do not manually copy installer files into airootfs when the maintained sync script owns that path.

Do not publish an ISO, write a disk, modify a live device, change a remote release/repository, or run destructive recovery/deployment actions without explicit authorization.

## Files and generated output

Keep code/operations contracts in `docs/` or the owning component docs. Project records belong under `$MEO_DOCS_ROOT/Projects/meo-arch-os-workspace/`; new generated output under `$MEO_OUTPUT_ROOT/meo-arch-os-workspace/{build,install,validation,packages,tmp}/`. Existing script-managed legacy build/artifact directories may remain; do not reorganize them as incidental work.

If required root variables are unset, do not invent machine-specific paths. Preserve unrelated dirty work and avoid `git reset`, `git clean`, or broad deletion.
