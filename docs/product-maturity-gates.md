# MeoArch product maturity gates

This document is a cross-repository release checklist. It does **not** expand the current milestone by itself and it does not replace `CURRENT_MILESTONE.md` or `production-readiness-matrix.md`. Its purpose is to stop source-complete components from being mistaken for a mature product before the user path, recovery path, security boundary, and release evidence are complete.

## Mature-product rule

A component is not mature merely because its feature exists or its CI is green. For a user-facing release, the supported path must have one owner, one authoritative backend, recoverable failure behavior, privacy/security boundaries that fail closed, an install/update path, and evidence at the runtime layer where the feature actually operates.

The release evidence ladder remains:

`Specified -> Implemented -> Build-tested -> Session-tested -> VM-tested -> Hardware-tested -> Release-ready`

A higher label must never be inferred from a lower one.

## P0 product gates

### 1. Boot, install, reboot, first login

Owner: `MeoArch-os-workspace` + `meo-login-manager` + packaged desktop components.

Release gate:

- current ISO boots through the supported UEFI path;
- Live Plasma and Installer both start and recover from Installer close/crash;
- destructive installation continues under its owning worker rather than the GUI lifetime;
- at least one clean VM can install, reboot, authenticate, and reach the intended Meo desktop;
- the same candidate is repeated enough to catch nondeterministic install/session failures;
- target locale, keyboard, user, network, package set and login/session state are read back after reboot;
- representative physical hardware is tested before claiming general hardware readiness.

### 2. Installer destructive/security boundary

Owner: `MeoArch-os-workspace/installer`.

Release gate:

- selected-disk identity is revalidated immediately before writes;
- state/credential directories and files are protected against symlink/TOCTOU substitution;
- install cancellation/crash never reports success or an ambiguous safe state;
- secrets do not enter ordinary selection state, logs, command lines or world-readable files;
- unsupported Secure Boot/encryption/partition layouts fail before destructive writes;
- if disk encryption is advertised, LUKS install, reboot, recovery and passphrase lifecycle are VM-tested. Otherwise the UI and release notes must state that encryption is unavailable.

### 3. Desktop/session security

Owner: `meo-kde` for the session desktop/lock authority; `meo-login-manager` for login-manager lifecycle.

Release gate:

- exactly one supported login path and one supported normal lock path;
- PAM/session authentication remains authoritative and credentials are never reimplemented in QML;
- lock acquisition/failure is tested in a real Wayland session;
- suspend/resume, screen-off, user switching where supported, and failed authentication do not expose the unlocked session;
- shell restart or component crash has a defined recovery result.

### 4. Daily Settings path

Owner: `MeoSettings`, consuming `Meo.System`/Qt/KDE owners.

Release gate:

- common network, Bluetooth, display, sound, power, appearance, input method, locale/time, default apps, privacy/accessibility and system/about flows work in a real session;
- pages do not present fake local state as successful configuration;
- each write re-reads authoritative state or returns a verified failure;
- advanced KDE handoff is deliberate rather than scattered through normal workflows;
- restore/backup copy describes its actual scope and never implies application/user-data restore when only portable presentation settings are restored.

### 5. Software/update trust path

Owner: `meo-repo` for package/release authority; `OmniStore` for store UX and transactions.

Release gate:

- one reviewed release manifest pins source/artifact identity for the candidate;
- packages/repository metadata are signed through protected release infrastructure;
- install/update/remove progress and failures come from the trusted transaction owner;
- published-repository smoke proves a clean client can resolve/install the candidate;
- update from the previous supported candidate is tested, including interrupted/failing update behavior;
- package licenses/provenance and source hashes are retained for bundled third-party runtime material.

### 6. Meo Account

Owner: `MeoArch-account`.

Release gate:

- system session/refresh credentials remain broker/KWallet-owned and are not returned to normal apps;
- OAuth login, expiry/refresh, logout, device/session revocation and offline/error states are exercised end to end;
- app capabilities are bound to installed executable identity and fail closed;
- user-facing privacy/export/delete-account behavior has a defined owner and clear failure state before a public account service is called production-ready;
- database migrations and web/Edge deployment remain protected release operations, not desktop-client authority.

### 7. Meo AI baseline

Owner: `meo-ai` for the assistant/frontend/service, `MeoArch-os-workspace/ai-router` for OS authority, `MeoArch-account` for account/credential brokerage.

Release gate:

- packaged native client and AgentService work together from a clean install without terminal setup;
- AgentService is started on demand or by an accepted session activation policy, with retry/recovery UI when unavailable;
- users can create, list and resume conversations; conversation history survives service restart;
- one real supported provider passes send/stream, attachment/resource, tool pause/deny/approve, cancellation and reconnect tests;
- a service crash never silently replays an uncertain tool/model operation; interrupted state is surfaced explicitly;
- System AI Router remains the authority for state-changing OS capabilities; model output, Skills and MCP descriptions never grant privilege;
- memory, MCP, model roles and controls report unsupported/preference-only states rather than pretending runtime behavior exists;
- native/web scope is explicit: activity/account sync must not be described as full conversation/provider parity unless that contract is actually implemented.

### 8. AI activity/usage data

Owner: `meo-ai` local collector + `MeoArch-account` cloud boundary.

Release gate:

- imports are idempotent and tolerate growing, truncated and rotated Codex/Claude history files;
- unchanged history is not fully reparsed on every refresh once the catalog becomes large;
- local database schema changes are versioned/migrated and corruption has a recoverable path;
- day/streak calculations have an explicit timezone policy;
- token semantics preserve source-specific cached/cache-write/reasoning fields and never imply cross-provider tokens are perfectly equivalent;
- longest-session UI is described as a session span unless real active-time/idle semantics are implemented;
- cloud sync is resumable/idempotent and never uploads prompts, transcript bodies, local absolute paths or credentials;
- cost is labelled as an estimate/API-equivalent estimate unless it is actual billed spend.

### 9. UI/accessibility/localization

Owners: `MeoUI` for reusable controls/tokens; owning apps for product flows; `meo-kde` for desktop surfaces.

Release gate:

- keyboard-only navigation and focus are usable across the supported P0 flows;
- accessibility names/roles exist for interactive controls and critical status/error surfaces;
- 100%, 125%, 150%/large-text and compact-window layouts do not clip critical actions;
- light/dark/dynamic-color and reduced-motion behavior remain coherent across first-party apps;
- at least English and the release's supported Chinese locale paths are checked for layout/translation regressions;
- offscreen screenshots are treated as visual regression evidence, not a substitute for a real Plasma session.

### 10. Recovery, diagnostics and supportability

Owners: owning component + `MeoArch-os-workspace/repair` for cross-system recovery.

Release gate:

- each first-party app has a useful empty/loading/offline/permission-denied/backend-crashed state;
- services expose status that can distinguish unavailable, starting, degraded and ready;
- local support diagnostics can report component versions, service state and bounded recent errors without exporting secrets or prompt/account contents by default;
- repair operations use typed bounded capabilities and destructive recovery requires explicit confirmation;
- a failed recovery action reports what did and did not change.

## Current high-priority gaps observed on 2026-10-10

These are evidence/implementation gaps, not a claim that every unlisted feature is complete:

1. The OS readiness matrix still marks the current ISO, VM install/reboot/first-login and physical-hardware evidence largely unverified. This is the largest difference between the present project and a mature release.
2. Installer private state-directory handling still has an open TOCTOU/symlink-hardening issue and remains release-significant because that state can contain credential-derived material.
3. Disk encryption is deliberately blocked by the current generator. A public release needs an explicit product decision: implement/test it or clearly ship without it.
4. Meo AI source CI is strong, and `meo-repo` already builds the native client plus inherited headless engine together. The native client now also requests the packaged AgentService on demand for the default endpoint. Remaining maturity work is installed-session startup/retry/recovery, conversation-library UX, and real-provider/real-tool acceptance.
5. AgentService exposes conversation listing/resume semantics, while the native product still needs a mature conversation-library UX rather than treating one current chat as the whole navigation model.
6. AI activity ingestion now has an explicit local schema marker, WAL/busy handling, unchanged-file fingerprints, idempotent growing-file re-import and a local-time day/streak policy. Remaining maturity gaps are a real schema migration/rebuild path, resumable cloud-upload cursor/ack state, and stable model/project normalization across aliases or moved repositories.
7. Account security boundaries are substantially stronger than ordinary prototype code, but production maturity still depends on end-to-end expiry/offline/recovery/session-management and privacy lifecycle acceptance rather than broker unit tests alone.
8. Meo Settings, MeoUI and Meo Desktop have broad source/offscreen coverage; real-session accessibility, scaling, localization and representative hardware behavior remain separate release evidence.
9. The release repository already provides pinned manifests, source hashes, package/repository workflows and published-repository smoke. New source commits after a pinned beta are not part of that beta until a new reviewed manifest/candidate is cut.

## Scope discipline

Do not respond to this document by implementing every item at once. The correct order is:

1. close security/data-loss defects;
2. make one clean install -> login -> daily-use path reliable;
3. make service/app activation and recovery automatic;
4. collect current VM/session/hardware evidence;
5. only then expand secondary feature breadth.

That ordering is what turns the current collection of capable components into one mature product rather than a larger collection of source-complete components.
