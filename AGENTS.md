# MeoArch OS Workspace agent rules

## Canonical repository

This is the active/canonical MeoArch OS ISO integration repository. The legacy `QwQdoge/MeoArch_os-workspace` repository is deprecated and must not be used for new work.

Inspect `git status`, the affected component, and its nearest tests/contracts first. Do not read every document or build the whole ISO unless the task requires it.

## Scope and documentation authority

Start with `docs/README.md` when a task crosses multiple product documents. `docs/CURRENT_MILESTONE.md` defines the current implementation scope; long-term product contracts are not automatic task lists.

- Do not implement a newly noticed feature merely because a long-term contract mentions it.
- Do not restore historical branch functionality merely because it is absent from current `main`.
- Expand scope only for the requested/current-milestone capability, work required to integrate it safely, or a security/data-loss correctness issue discovered directly in that work.
- Record unrelated bugs, missing features, architecture improvements, and technical debt for a separate task instead of implementing them automatically.
- Keep evidence levels distinct: `Specified`, `Implemented`, `Build-tested`, `Session-tested`, `VM-tested`, `Hardware-tested`, and `Release-ready` are not interchangeable.

Repository consolidation, review, validation, and cleanup must not silently become open-ended feature development.

## Ownership and cross-repository boundaries

- `installer/`: installer app, backend, tests, translations, and live Meo.System bridge.
- `repair/`: Quick Repair source, checks/actions, privileged service, knowledge, and tests.
- `meoarch-os/`: authoritative ArchISO profile, package list, boot config, and airootfs inputs.
- `scripts/`: staging, build, acceptance, bootstrap, and verification entry points.
- `assets/`, `configs/`, `themes/`: ISO-owned versioned inputs.
- Generic reusable QML/tokens/motion belong in MeoUI via `$MEO_UI_ROOT`.
- Plasma/KWin/Meo.System desktop integration belongs in meo-kde via `$MEO_KDE_ROOT`.
- Do not copy sibling repositories into this worktree or treat staged airootfs files as source authority.

## Runtime system information

Treat machine, session, hardware, service, account, package, capability, and current-configuration facts as runtime state rather than UI copy.

- If a value can legitimately differ between installations or change while the system is running, detect/read it from the authoritative owning API or system source whenever practical instead of hard-coding a production value.
- Prefer stable Qt/KDE/native APIs and documented Meo.System contracts. Use stable read-only kernel/system interfaces only when no suitable owner API exists; do not parse generic command output when a maintained native API is available.
- Never ship guessed or plausible placeholder system facts to make a UI look complete. When reliable detection is unavailable, expose an explicit unavailable/unknown state, hide the hardware-specific presentation, or disable the capability with a real explanation.
- Keep mutable facts reactive where practical and re-read authoritative state after a requested change instead of assuming success. Snapshot or expensive facts should have a deliberate refresh path.
- Test/preview fixtures may use deterministic fake values only behind explicit test/preview code paths; production startup must not silently fall back to them.
- Product constants such as branding, translated UI copy, design tokens, stable protocol identifiers, and the compile-time version of the exact component being run may remain static. A fallback label must not impersonate detected system information.

For Meo Settings, the detailed contract lives in `QwQdoge/MeoSettings` as `docs/RUNTIME_SYSTEM_INFORMATION.md`. Apply the same principle to Installer, Repair, system-monitoring, shell, login/lock, and future system-facing components.

## AI router and MCP boundary

For AI-driven system actions, the **System AI Router** is the canonical orchestration boundary. Preserve the internal flow:

`user request -> intent -> capability -> policy/permission/confirmation -> owning app or system executor -> verification -> structured result`.

- Keep MeoArch internal capabilities authoritative. MCP is an interoperability/tool-adapter layer, not a replacement for the internal intent/capability/policy model.
- Meo AI may act as an MCP client/host for approved external MCP servers. MeoArch may also expose selected approved capabilities through a MeoArch MCP server for external agents.
- Native MeoArch actions such as audio, Bluetooth, Wi-Fi, launcher, window, settings, notification, power, and file operations should call their owning native APIs/adapters directly when available instead of being split into one MCP server per feature.
- Prefer one maintained `meo-mcp-gateway` (or equivalent shared adapter boundary) over per-app MCP servers unless isolation, deployment, trust, or versioning requirements justify a separate server.
- Every MCP tool that can change system state must map to a named MeoArch capability with typed/validated inputs and must pass through the same policy, permission, confirmation, and authorization checks as native AI actions.
- Never let MCP bypass `CapabilityRegistry`, policy checks, the owning application boundary, or the verification stage.
- Meo AI may provide a directly model-driven terminal only through the dedicated sandboxed workspace capability. The user must explicitly grant a workspace; only that workspace may be writable; networking is a separate permission; host root, unrelated user data, system/session D-Bus and ambient provider/session secrets must remain outside the sandbox.
- Do not expose the sandboxed terminal through external MCP, and do not expose an unrestricted host `shell.exec`, arbitrary `sudo`, root command runner, or equivalent generic privileged command-execution tool to the model. Privileged operations must be represented as narrow audited capabilities.
- Treat third-party/remote MCP servers and their outputs as untrusted integration boundaries. Validate schemas and returned data, minimize shared context/secrets, and preserve existing sandbox/authentication boundaries.
- New app integrations should register explicit intents/capabilities and implement a native or MCP adapter behind them; do not encode provider-specific execution logic directly into the system prompt.
- After any state-changing tool call, verify the resulting state when practical and return a structured success/failure result instead of assuming execution succeeded.
- When extending this architecture, preserve the existing security contracts and update the nearest AI/router/security documentation and tests together with the implementation.

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
