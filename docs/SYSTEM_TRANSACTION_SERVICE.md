# Meo System Transaction Service

`org.meo.SystemTransaction1` is the narrow system-bus boundary for Meo-owned system configuration transactions that require a trusted system authority.

The first implementation is deliberately **read-only**. It exists to make request validation and planning real before any privileged writer is added.

## Bus contract

- bus: system bus
- service: `org.meo.SystemTransaction1`
- object: `/org/meo/SystemTransaction1`
- interface: `org.meo.SystemTransaction1`

### `Inspect`

```text
Inspect(string kind, a{sv} request) -> a{sv}
```

`Inspect` performs no mutation and requires no authorization. It validates a closed request shape and returns either a structured plan or a structured rejection.

Current supported request:

```text
kind = "configuration"
configurationId = "session-entry.login.v1"
operation = "inspect" | "plan"
payload = session-entry login presentation map
```

The service must reject unknown transaction kinds, configuration IDs, request fields, unsafe login-scope values, and all mutating operations in v0.1.

A successful result contains at least:

```text
ok = true
state = "planned"
kind = "configuration"
configurationId = "session-entry.login.v1"
mutable = false
authorizationRequired = false
schemaVersion = 1
scope = "login"
```

A rejected result contains at least:

```text
ok = false
state = "rejected"
errorCode = <stable code>
message = <human-readable explanation>
```

## Login session-entry policy

The `session-entry.login.v1` configuration is pre-login presentation state, not authenticated user-session state.

The read-only validator therefore enforces the important login-scope restrictions before a future writer exists:

- `scope` may only be `login`;
- media, weather and audio session modules are disabled;
- `weatherCity` is empty;
- notification visibility is `hidden`;
- album artwork is disabled;
- weather-location exposure is limited to `hidden` or `city`;
- wallpaper mode is managed rather than a current-user wallpaper reference.

The complete source schema remains `meo-kde/docs/schemas/meo-session-entry-v1.schema.json`. The system transaction service owns the privileged-system validation boundary and must stay at least as strict as that schema for `scope=login`.

## Future mutation contract

No mutating D-Bus method is part of v0.1. Adding one requires all of the following in the same implementation change:

1. typed operation and payload validation;
2. caller-aware Polkit authorization for the exact capability;
3. snapshot of the authoritative current state;
4. bounded apply through the owning login-manager configuration authority;
5. post-write validation/readback;
6. commit only after validation;
7. rollback on failure;
8. stable structured result/error codes;
9. no direct PAM mutation from Meo Settings or QML;
10. tests for rejection, authorization, validation failure and rollback.

The intended state-changing sequence is:

```text
Inspect -> Validate -> Plan -> Preview -> Authorize
-> Snapshot -> Apply -> Validate -> Commit / Rollback
```

The system service may run as root, but its API must never become a generic root command executor, path writer, shell bridge, or arbitrary configuration-file editor.

## Service hardening

The v0.1 systemd unit runs with a read-only filesystem view, private temporary directory, no device access, no new privileges, and only `AF_UNIX` networking. These restrictions should be relaxed only for a specific implemented transaction that demonstrably requires it.

The D-Bus policy allows unprivileged callers to invoke only the read-only `Inspect` method. Future state-changing methods must not be opened through the same unrestricted policy; they need their explicit authorization design first.
