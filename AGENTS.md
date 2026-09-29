# DEPRECATED — DO NOT USE FOR NEW WORK

This repository is no longer the active MeoArch OS workspace. The canonical repository is:

**QwQdoge/MeoArch-os-workspace**  
https://github.com/QwQdoge/MeoArch-os-workspace

Agent requirements:
- Do not implement new features, fixes, refactors, packaging, release work, CI work, or documentation updates here, except changes whose sole purpose is deprecation/migration.
- Treat this checkout as read-only historical material unless the user explicitly asks for migration work.
- If this repository contains content missing from the canonical repository, compare it first, migrate only the still-relevant content to the canonical repository, validate there, and leave the canonical repository as the source of truth.
- Do not publish, build a release from, or point automation at this repository.
- Prefer the canonical repository immediately when a task concerns MeoArch OS, the installer, repair tooling, ArchISO, ISO staging, or release integration.

---

# Deprecated MeoArch workspace

This repository is deprecated. The canonical repository is:

`QwQdoge/MeoArch-os-workspace`

The current HEAD of this underscore repository is already present in the canonical repository's Git history, and later canonical commits intentionally replaced or removed legacy boot/theme/runtime files.

## Agent rule

Do not make new source, documentation, build, packaging, or release changes in this repository. Do not migrate removed files back merely because they exist here. Perform all new work in `QwQdoge/MeoArch-os-workspace`.

This repository is retained only until it can be deleted through a GitHub administrative interface. No deployment, release, ISO build, or cleanup work should originate here.
