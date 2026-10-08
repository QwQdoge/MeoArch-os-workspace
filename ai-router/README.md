# MeoArch System AI Router

This component is the typed orchestration boundary between Meo AI/model output and MeoArch-owned application/system capabilities.

It intentionally does **not** provide a generic shell, sudo bridge, arbitrary executable runner, or model-controlled path/argument interface.

## Current foundation

Implemented now:

- typed `CapabilityRegistry` with stable IDs, owners, effects, privilege metadata, confirmation policy, JSON input schemas and executor identity;
- deterministic input/policy validation before dispatch;
- caller and request-origin binding (`native` / `mcp`);
- exact state-change confirmation enforcement;
- structured `CapabilityResult` values;
- a default Meo Settings executor using fixed compiled routes;
- an MCP adapter that exports only explicitly approved executable capabilities;
- dynamic first-party capability/executor registration for future owning components;
- a contract test covering schema rejection, confirmation boundaries, unavailable adapters and MCP mapping.

Currently executable built-ins:

- `settings.wifi.open`
- `settings.bluetooth.open`
- `settings.audio.open`
- `settings.display.open`
- `settings.appearance.open`

The route is compiled into the capability descriptor. Model/tool input cannot provide a program, route, path or command.

Declared but deliberately unavailable until their owning typed services exist:

- `network.status.read`
- `bluetooth.status.read`
- `system.performance.summary`
- `file.search`
- `desktop.audio.setVolume`
- `application.launch`

This is intentional. The Router must return `capability_unavailable` rather than reimplement these authorities with shell parsing.

## Flow

```text
untrusted intent / MCP tool
        ↓
CapabilityRegistry lookup
        ↓
strict schema validation
        ↓
policy + caller/origin + confirmation
        ↓
owning executor
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

The CLI invocation accepts only a registered capability ID and currently supports the no-input built-ins. It is not a command execution interface.

## Next adapters

Add adapters only behind maintained owning APIs. Priority order follows `docs/design.md` and `docs/unfinished-work.md`:

1. shared read-only network/Bluetooth state;
2. shared audio state and bounded volume control;
3. application launch by validated desktop-app identity;
4. shared performance summary;
5. file search through an owning search service;
6. first-party app action registration;
7. MCP transport/server wiring around the existing adapter, without bypassing this Router.
