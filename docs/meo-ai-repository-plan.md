# Meo AI repository boundary and migration plan

Status: proposed extraction target for a dedicated `QwQdoge/meo-ai` repository.

This document defines source ownership and migration order. It does not make AI a privileged system authority: repository ownership and runtime privilege boundaries are separate concerns.

## 1. Product boundary

`meo-ai` should own the user-facing Meo AI product and the reusable agent runtime around it:

- Meo AI assistant UI and session runtime;
- System AI Router and typed capability registry;
- provider abstraction and model invocation client code;
- shell, file, application and other agent tools;
- Skills and MCP integration;
- memory, document/RAG and scheduled-agent facilities when implemented;
- repair orchestration, repair knowledge and the standalone Quick Repair UI/CLI;
- tests and security contracts for these components.

The following remain outside `meo-ai`:

- **Meo Account**: account identity, OAuth, broker grants, connection metadata and account-owned credential storage remain in `MeoArch-account`;
- **Meo.System**: shared NetworkManager/BlueZ/PipeWire/KScreen/power/telemetry authority remains a platform API because Settings, Shell, Widgets and Performance Manager also consume it;
- **SystemTransaction**: privileged configuration transaction service remains a separate narrow system authority and must not become an AI root bridge;
- package transactions remain owned by OmniStore/package services.

`meo-ai` may be the source repository for the repair privileged service, but the service must remain a separately installed root-owned process with its existing D-Bus/Polkit boundary. Source co-location never grants the assistant root authority.

## 2. Target repository layout

```text
meo-ai/
├── CMakeLists.txt
├── README.md
├── docs/
│   ├── architecture.md
│   ├── security.md
│   ├── capabilities.md
│   ├── shell-tool.md
│   └── repair.md
├── app/
│   ├── main.cpp
│   └── qml/
├── runtime/
│   ├── session/
│   ├── providers/
│   ├── context/
│   └── tool-runtime/
├── router/
│   ├── router.cpp
│   ├── router.h
│   ├── service.cpp
│   ├── service.h
│   └── data/
├── tools/
│   ├── shell/
│   ├── files/
│   ├── applications/
│   └── system/
├── skills/
├── mcp/
├── memory/
├── repair/
│   ├── core/
│   ├── app/
│   ├── qml/
│   ├── checks/
│   ├── actions/
│   ├── knowledge/
│   ├── privileged/
│   ├── live-actions/
│   ├── data/
│   ├── translations/
│   └── tests/
└── tests/
```

The repository can build multiple packages/executables. `meo-ai`, `meo-ai-router`, `meoarch-repair` and `meoarch-repair-privileged-service` do not need to share one runtime process.

## 3. Current source locations to extract

### System AI Router

Current source: `QwQdoge/meo-kde/native/airouter/`.

Move to `meo-ai/router/` while preserving:

- typed `Capability` registration;
- caller-bound requests;
- argument type validation;
- action fingerprinting;
- irreversible-action confirmation and expiry;
- result lifecycle and readback/verification behavior;
- D-Bus service entry.

After extraction, `meo-kde/native/CMakeLists.txt` must stop building `airouter`; Meo Desktop should depend on the packaged Router service instead of owning its source.

### Quick Repair

Current source: `QwQdoge/MeoArch-os-workspace/repair/` plus `installer/app/repaircontroller.cpp` and `installer/app/repaircontroller.h`.

The current build has an inverted dependency: `repair/CMakeLists.txt` builds `meoarch-repair-core` using the controller from the Installer tree. Before final extraction, move ownership of `RepairController` into Repair/AI code and make the Installer consume the repair component rather than Repair consuming Installer source.

Recommended split:

```text
repair/core/
  RepairController / orchestration
  CapabilityRegistry
  AgentState
  SessionJournal

repair/providers/
  account broker client
  local provider client

repair/diagnostics/
  finding/evidence collection

repair/execution/
  fixed action dispatch / verification
```

The standalone Quick Repair executable remains supported even after Meo AI embeds the same repair flow. Recovery must remain usable when the assistant UI, account broker, provider, network or normal desktop session is unavailable.

## 4. Repair inside Meo AI

Repair is a first-party Meo AI capability family, but not merely a shell prompt.

Normal flow:

```text
User
 -> Meo AI
 -> repair.inspect / repair.diagnose
 -> versioned local runbook + structured evidence
 -> optional model proposal
 -> deterministic validation / risk review
 -> exact confirmation when required
 -> fixed repair capability
 -> privileged repair service when required
 -> post-check / rollback / result
```

The assistant may open an embedded repair surface or hand off to the standalone `meoarch-repair` executable. Both must share `repair-core`, knowledge, schemas and action IDs.

Do not reimplement Repair as `shell.exec("sudo ...")`.

## 5. Shell tool

A shell tool is allowed and useful for general Linux-agent workflows.

It should be a first-class tool, not a hidden bypass around typed capabilities.

Initial contract:

```text
shell.exec
  command: string
  cwd: optional path
  timeoutMs: bounded integer
  environment: allowlisted additions
```

Rules:

- execute as the current unprivileged user by default;
- no implicit `sudo`, `pkexec`, `su`, or password handling;
- bounded timeout and output size;
- preserve exit code, stdout and stderr separately;
- show/record the exact command before destructive or high-risk execution;
- classify obvious destructive commands for explicit confirmation;
- allow persistent terminal sessions later as a separate capability;
- prefer typed Meo.System capabilities for common OS state/control because they provide structured state and verification;
- privileged repair/configuration/package work continues through the owning services.

This keeps Nyarch/Newelle-style flexibility without throwing away the Meo OS API and security model.

## 6. Account relationship

`meo-ai` is a client of Meo Account, not part of it.

Meo Account continues to expose broker/connection/grant APIs. Meo AI may also support explicitly configured local providers without signing in, but account-backed credentials and managed inference stay owned by Meo Account.

The current Router has account-broker calls mixed into its routing service. During extraction, split these into a provider/inference client so the Router itself only receives a validated intent result and dispatches typed capabilities.

Target dependency:

```text
Meo AI runtime
   ├─ local provider client
   └─ Meo Account broker client -> org.meo.Accounts1

System AI Router
   -> typed intent/capability only
```

## 7. Meo.System relationship

Do not move `meo-kde/native/system` wholesale into `meo-ai`.

The system backend is shared platform infrastructure. AI should depend on it exactly like Settings, Quick Settings and Widgets do.

Example:

```text
Meo AI -> Router -> org.meo.desktop.audio.setVolume
                    -> Meo.System Audio API
                    -> PipeWire
                    -> readback
```

The existing Router's direct PulseAudioQt adapter is acceptable as a temporary implementation, but should converge on the shared Meo.System audio authority after extraction.

## 8. Migration order

1. Create empty `QwQdoge/meo-ai` repository.
2. Add root build, CI, README, architecture/security contracts and package names.
3. Extract `meo-kde/native/airouter` into `meo-ai/router` without behavior changes; run existing Router tests.
4. Decouple account inference from Router dispatch into `runtime/providers/account`.
5. Move `RepairController` ownership out of `installer/app` into Repair core, keeping a compatibility integration for Installer/Live entry.
6. Extract `repair/` into `meo-ai/repair` and run existing core/AI-flow tests.
7. Add `tools/shell` with unprivileged bounded execution and confirmation policy.
8. Add the assistant runtime/UI and provider abstraction.
9. Add capability adapters for Meo.System, app launch, settings deep links, files and performance queries.
10. Only after destination builds/tests pass, remove duplicated Router/Repair sources from `meo-kde` and workspace and switch package/build references to the new repository.

Do not delete the current source first. Extraction is copy/build/test/switch/remove, not move-and-hope.

## 9. First milestone

The first usable `meo-ai` milestone should support:

- text chat with OpenAI-compatible and Ollama/local provider paths;
- local/offline routing for known deterministic commands;
- application launch and Settings deep links;
- get/set audio volume with verification;
- unprivileged shell execution with explicit high-risk confirmation;
- Quick Repair embedded entry plus standalone `meoarch-repair`;
- Account broker as optional managed-provider source;
- no root shell and no generic SystemTransaction escape hatch.

A successful demo is:

```text
"看看为什么电脑有点卡，把音量调到 30%，再打开蓝牙设置。"

Meo AI
 -> performance summary
 -> verified audio capability
 -> Settings deep link
 -> response with observed results
```

Shell remains available for tasks that do not yet have a typed platform capability, while common OS controls progressively converge on Meo.System.
