# MeoArch repository architecture

This document defines source-of-truth boundaries across the nine repositories that currently participate in the MeoArch desktop/product stack. When ownership is ambiguous, this document and the owning repository's local contract win over historical placement.

## Repository map

| Repository | Owns | Does not own |
| --- | --- | --- |
| `MeoArch-os-workspace` | ArchISO profile, installer, repair, System AI Router, OS integration/configuration, cross-repository compatibility and acceptance, release/ISO orchestration | Reusable MeoUI controls, Plasma shell implementation, standalone app implementations, package repository payload authority |
| `meo-kde` | Plasma/KWin integration, Meo Desktop session/shell, plasmoids, Meo.System, KDE-native bridges, desktop themes/layout defaults, lock/session desktop integration | Reusable platform-neutral UI primitives, application-specific business logic, ISO orchestration |
| `MeoUI` | Platform-neutral Material 3 Expressive tokens, controls, patterns, motion, responsive UI contracts, widget presentation primitives, Showcase | Plasma/KWin/DBus/system policy, app backends, package management |
| `MeoSettings` | Meo Settings application and its settings-specific native/runtime integration contract | Shared shell UI, package store, ISO ownership |
| `OmniStore` | Store/search/install/update product logic, source/plugin model, Python backend/daemon, current native client, transitional legacy clients | Shared OS shell/UI primitives, repository publication authority |
| `meo-ai` | Meo AI assistant/frontends, headless assistant service, provider/agent integration, client adapters to System AI Router, temporary Newelle compatibility while migration remains active | System AI Router authority, privileged OS executors, duplicated Meo.System implementations |
| `meo-repo` | Arch package recipes, release manifests, repository/release validation, signing/publication workflows and metadata contracts | Application source implementations, ISO source tree, long-term binary artifact storage once R2 migration completes |
| `meo-login-manager` | Meo login/display-manager integration and its upstream-compatible KDE/SDDM-derived source | Desktop session implementation, settings/store/app source |
| `kde-plasma6-widgets` | Third-party/upstream widget staging and compatibility source collection | Meo shell architecture, Meo first-party widget product policy, source-of-truth MeoUI components |

## Workspace rule

`MeoArch-os-workspace` is an integration repository, not a general application monorepo. New standalone app implementation must not be added here when an owning application repository exists. Cross-repository glue, system services, ISO-specific configuration, acceptance tests, and orchestration may live here.

`ai-router/` is intentionally owned here because the System AI Router is an OS orchestration/security boundary. `meo-ai` is its client/assistant product, not its replacement.

## Current/compatibility/legacy rule

Repositories that contain migrations must explicitly classify implementations as one of:

- **Current**: production direction and default implementation.
- **Compatibility/optional**: maintained only for interoperability, migration, fallback, or explicitly optional use.
- **Legacy**: retained for provenance or temporary migration; must not be selected for new feature work unless a migration task specifically requires it.
- **Experimental**: not a product default and must not silently become one.

A historical implementation being present in a repository is not evidence that it remains current.

## Dependency direction

Preferred dependency direction:

`MeoUI -> applications / meo-kde -> workspace integration -> meo-repo packaging/release`

System-facing ownership remains with its native authority. Application code should consume typed Meo.System/System AI Router interfaces rather than copying the owning backend.

## Artifact policy

Source repositories own source and reproducible release metadata. Durable binary package/ISO artifacts should move to release/object storage rather than growing Git indefinitely. `meo-repo/x86_64/` remains authoritative until the R2-backed release path is complete and explicitly migrated; it must not be deleted early.

## Change rule

Before adding a new subsystem, answer:

1. Which repository owns the reusable API/UI contract?
2. Which repository owns the runtime/system authority?
3. Which repository owns packaging/release metadata?
4. Is the proposed code integration glue or a product implementation?

If two repositories would own the same implementation, stop and resolve the boundary before adding a second copy.
