# MeoArch System AI Router

This component is the typed orchestration boundary between Meo AI/model output and MeoArch-owned application/system capabilities.

It does not make the Router itself a root shell or generic privileged executor. Model-selected actions still pass through capability lookup, policy and the owning execution boundary.

## Current foundation

Implemented now:

- typed `CapabilityRegistry` with stable IDs, owners, effects, privilege metadata, confirmation policy, JSON input schemas and executor identity;
- deterministic input/policy validation before dispatch;
- caller and request-origin binding (`native` / `mcp`);
- one-shot expiring confirmation grants bound to capability + exact input + caller + origin + granted permissions + policy version;
- structured `CapabilityResult` values;
- a default Meo Settings executor using fixed compiled routes;
- an MCP adapter that exports only explicitly approved executable capabilities;
- dynamic first-party capability/executor registration for future owning components;
- a contract test covering schema rejection, exact confirmation binding, unavailable adapters and MCP mapping.

Currently executable built-ins:

- `settings.wifi.open`
- `settings.bluetooth.open`
- `settings.audio.open`
- `settings.display.open`
- `settings.appearance.open`

The Settings route is compiled into the capability descriptor. Model/tool input cannot replace it with another program, path or route.

Declared but deliberately unavailable until their owning typed services exist:

- `network.status.read`
- `bluetooth.status.read`
- `system.performance.summary`
- `file.search`
- `desktop.audio.setVolume`
- `application.launch`

The Router must return `capability_unavailable` rather than silently replacing these authorities with ad-hoc shell parsing.

## LLM terminal contract

`terminal.workspace.run` is now a registered first-party capability contract.

Target product behavior:

1. the user grants Meo AI terminal access to an explicit workspace/session;
2. the LLM may run normal development/inspection commands in that workspace without a modal confirmation before every command;
3. the runner may modify the granted workspace because that is the purpose of the permission;
4. host root, unrestricted `$HOME`, unrelated user data and privileged system mutation are not implied by this grant;
5. the terminal capability is **not exported through MCP**;
6. privileged system work continues through narrow typed capabilities and Polkit/owning services.

The capability currently remains `executable=false` until the separate sandbox runner exists. Do not implement it as Router-local `sh -lc <model text>` or an unrestricted `shell.exec`. A real sandbox boundary must be available first.

## Flow

```text
untrusted intent / MCP tool
        ↓
CapabilityRegistry lookup
        ↓
strict schema validation
        ↓
permission + caller/origin + bound confirmation policy
        ↓
owning executor / sandbox runner
        ↓
structured result / verification state
```

## Build and test

With Qt 6.6+ Core available:

```bash
cmake -S ai-router -B ai-router/build
cmake --build ai-router/build
ctest --test-dir ai-router/build --output-on-failure
```

Inspection CLI:

```bash
meo-ai-router --list
meo-ai-router --list-mcp
meo-ai-router --invoke settings.bluetooth.open
```

The CLI invocation accepts only a registered capability ID and currently supports the no-input executable built-ins. It is not the terminal runner.

## Next adapters

Priority order:

1. sandbox process/service for `terminal.workspace.run` with explicit workspace grants and bounded output/time/resource handling;
2. shared read-only network/Bluetooth state;
3. shared audio state and bounded volume control;
4. application launch by validated desktop-app identity;
5. shared performance summary;
6. file search through an owning search service;
7. first-party app action registration;
8. MCP transport/server wiring around the existing adapter, without bypassing this Router.
