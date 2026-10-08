# MeoArch System AI Router

This component is the typed orchestration boundary between Meo AI/model output and MeoArch-owned application/system capabilities.

The Router is not a root shell. It supports a directly model-driven **user terminal inside an explicitly granted workspace sandbox**, while privileged/system mutations remain typed capabilities owned by their real service.

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
- a sandboxed LLM terminal executor for an explicitly granted workspace;
- contract tests for schema rejection, exact confirmation binding, terminal permissions, unavailable adapters and MCP mapping.

Currently executable built-ins:

- `settings.wifi.open`
- `settings.bluetooth.open`
- `settings.audio.open`
- `settings.display.open`
- `settings.appearance.open`
- `terminal.workspace.run`

The Settings route is compiled into the capability descriptor. Model/tool input cannot replace it with another program, path or route.

Declared but deliberately unavailable until their owning typed services exist:

- `network.status.read`
- `bluetooth.status.read`
- `system.performance.summary`
- `file.search`
- `desktop.audio.setVolume`
- `application.launch`

The Router returns `capability_unavailable` rather than silently replacing those maintained authorities with ad-hoc shell parsing.

## Direct LLM terminal

`terminal.workspace.run` lets the LLM choose and execute ordinary shell commands directly after the user grants the `terminal.workspace` permission.

The current runner:

- requires `MEO_AI_WORKSPACE_ROOT` to point to the explicitly granted host workspace;
- exposes only that workspace as writable at `/workspace`;
- runs through `bubblewrap` with a new user/PID/IPC/UTS/cgroup namespace and all Linux capabilities dropped;
- exposes `/usr` and `/etc` read-only, plus private `/tmp`, `/proc` and `/dev`;
- clears the host environment so provider keys/session secrets are not inherited;
- does not mount host system/session D-Bus sockets;
- rejects a `cwd` that resolves outside the workspace, including symlink escapes;
- caps command length, execution time and captured output;
- disables networking by default; a separate `terminal.network` permission enables host-network access;
- is never exported through the external MCP gateway.

This means Meo AI can do normal terminal work such as builds, tests, Git operations and source edits inside the granted workspace without converting every command into a typed capability. Host root and system configuration are still outside that grant. `sudo`, package/system service changes, disk operations and other privileged work must go through the appropriate Meo-owned typed capability/service.

A future persistent PTY/session layer can build on the same permission and sandbox contract; the first implementation is bounded command execution.

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

The terminal runtime additionally requires `bwrap` (`bubblewrap`).

Inspection CLI:

```bash
meo-ai-router --list
meo-ai-router --list-mcp
meo-ai-router --invoke settings.bluetooth.open
```

The inspection CLI remains capability-oriented; model terminal permission should be granted by the Meo AI/session UI rather than by an ambient global default.

## Next adapters

Priority order:

1. persistent PTY/session support on top of the same workspace sandbox contract;
2. shared read-only network/Bluetooth state;
3. shared audio state and bounded volume control;
4. application launch by validated desktop-app identity;
5. shared performance summary;
6. file search through an owning search service;
7. first-party app action registration;
8. MCP transport/server wiring around the existing adapter, without exposing the terminal capability.
