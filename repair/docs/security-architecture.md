# MeoArch Repair security architecture

MeoArch Repair uses AI for bounded classification, explanation, and proposal.
AI is not an authorization authority and cannot supply a command, executable,
path, argument, device identifier, package, URL, or privilege decision.

## Authority chain

The local state machine is authoritative:

```text
INIT -> CLASSIFY -> COLLECT -> ASK/WAIT_USER -> COLLECT_MORE
     -> BUILD_PLAN -> REVIEW -> WAIT_CONFIRM -> AUTHORIZE
     -> EXECUTE -> VERIFY -> DONE
```

`CANCELLED`, `FAILED`, and `HANDOFF` are terminal states. A model response may
be considered only in the state that requested it. It cannot transition the
machine, skip confirmation, or resume execution after a crash.

The approval chain is monotonic:

```text
schema validator -> deterministic policy -> reviewer -> user confirmation
                 -> Polkit -> executor precondition/postcondition checks
```

Later stages may reject an operation but cannot override an earlier rejection.
The reviewer is an additional restriction layer, not a safety root.

## Capability policy

Every capability is compiled into `core/capabilityregistry.cpp`. Its
`effect`, `privilege`, `reversibility`, and `exportability` are separate
properties. UI risk labels must not be used as privilege decisions. A
destructive or `executable=false` capability is never dispatched even if a
model returns its identifier.

On an installed system, `PrivilegedRepairService` owns `org.meo.Repair1` on the
system bus and exposes four argument-free methods. Each method performs a
Polkit check against the unique system-bus caller, then runs one fixed internal
implementation. It never accepts a command, path, argument list, capability
name, model value, or device name. The Live image remains a separate domain:
its local `live` user may invoke only the exact image-owned wrappers selected by
the existing Live Polkit rule.

Package acquisition is a separate user-visible handoff. Repair maps a small
set of evidence codes to fixed capability IDs, and those IDs to compiled native
package identifiers. It starts `/usr/bin/omnistore` with the public typed
argument contract `install <package-id> --source native`; neither the plan nor
the model supplies any argument. Repair then enters `HANDOFF` rather than
claiming that installation succeeded. OmniStore owns the **Download / Cancel**
dialog, package task, operating-system authorization, and result. The user must
return to Repair and collect a new evidence snapshot before any further action.

## Evidence and confirmation binding

AI receives field-first finding codes, explicit guided answers, the selected
scope/category, and the user's own problem statement. Raw command output and
human-readable finding text stay local. Device names are UI-only and actions
use locally resolved opaque identifiers.

After collection, Repair freezes an evidence snapshot. A plan is bound to:

- the complete local plan object;
- an SHA-256 hash for every action;
- the target evidence snapshot ID;
- the deterministic policy version;
- an expiry time; and
- a random session nonce.

Any change invalidates confirmation. A failed action cannot append a fallback
write; a new write requires a new snapshot, plan, review, and confirmation.

## Crash recovery

Before execution and around every action, Repair writes a private append-only
JSONL journal containing only schema IDs, hashes, state, action ID/index, and
timestamps. It never stores raw logs, prompts, device names, paths, secrets, or
credentials. If the last event is not terminal, the next launch enters
`recover_needed`; it does not replay the action and asks for a fresh matching
diagnostic and verification.

## Category closure

All nine categories must diagnose and end in a verified result or an explicit
handoff. They do not all receive automatic writes. Storage-destructive repair,
graphics driver changes, and suspected-compromise remediation are declared
non-executable in the first-release registry.

Network configuration changes must use NetworkManager D-Bus checkpoints before
they are added. After a potentially disconnecting action begins, execution and
verification must not depend on a cloud model. Display changes keep their
separate 15-second external rollback and visual “keep settings” confirmation.
