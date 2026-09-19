# MeoArch Quick Repair

This folder is the shared source for the installed-system troubleshooter and
the Live ISO repair entry. Both surfaces use the same controller, MeoUI QML,
fixed diagnostic scripts, action allowlist, consent dialog, plan schema, risk
review schema, plan hash, and exact confirmation phrase.

AI is optional. Read-only category checks work without an account or API key.
Local provider keys can be kept for the current process only or stored through
QtKeychain with insecure fallback disabled. MeoArch Account is an optional
broker source and never returns provider keys to this app.

Meo Settings can open the graphical app directly in one matching flow without
constructing a command or copying the repair logic:

```text
meoarch-repair --category audio
meoarch-repair --category display
```

The CLI only runs fixed read-only checks:

```text
meoarch-repair --cli --category=all
meoarch-repair --cli --category=network
meoarch-repair --cli --category=audio
meoarch-repair --cli --category=display
```

Write actions are fixed implementations selected by typed IDs. On an installed
system, the unprivileged Repair client calls one of four argument-free methods
on the root-owned `org.meo.Repair1` system D-Bus service. The service performs
an action-specific Polkit check against the D-Bus caller and never accepts a
command, path, arguments, or model-provided identifier. In Live mode, a Live-
image-only Polkit rule grants the active local `live` user
access to four separate, argument-free Live wrappers. Each wrapper hard-codes
the Live scope and `/mnt` target before calling the corresponding backend;
target-aware actions still require a validated system mounted at `/mnt`. The
normal installed-system scripts are not covered by the Live rule. No AI
response is interpreted as a command, path, argument list, package name, or
URL. When evidence shows that one of a small set of diagnostic tools is
missing, a typed capability may open the public OmniStore command
`omnistore install <package-id> --source native`. The package identifier is a
compiled local mapping, never model output. OmniStore owns the separate
**Install / Cancel** confirmation and starts its existing task only after the
user confirms.

The executable security contract is documented in
[`docs/security-architecture.md`](docs/security-architecture.md). The local
state machine, capability registry, evidence snapshot binding, and private
crash journal are compiled into the application; reviewer output can only
tighten an already-valid deterministic decision.

## Help and repair interaction contract

The default UI is a normal MeoUI help page: a search field and grouped problem
categories on the left, with the selected category, a large automatic-check
action, status, evidence, and a problem-description field on the right. A
category selection or submitted description starts the matching read-only
diagnostics immediately. Natural-language classification is local and selects
only a fixed diagnostic category. AI can propose a question only when the
current evidence is insufficient; the retired one-question-at-a-time wizard is
not the primary navigation model. Account sign-in remains optional and is
recommended in the UI for managed AI access.

When no deterministic audio fault is found the app can launch one fixed
`speaker-test` invocation and ask whether the user actually heard it. After a
repair it repeats the same human verification; when multiple outputs exist, a
failed listening test returns to device selection so the user can try another
speaker, headset, or HDMI output. Audio
repairs use the existing `Meo.System` user-session backend. Display recovery can
only enable a connected, disabled KScreen output. Before changing the layout it
must successfully create a user-level systemd rollback timer for that exact,
bounded output ID. The in-app confirmation lasts 15 seconds; the external timer
still disables the output if the app exits. Keeping the display requires
cancelling that timer, and both apply and rollback states are post-checked.
The Live image and installed desktop explicitly include `alsa-utils`,
`pipewire-audio`, `pipewire-pulse`, and `wireplumber`, matching the fixed test
sound and the three user services that audio repair restarts and verifies. The
Live repair entry runs as the `live`
user with a real user manager and device-group access; it does not run the AI
or user-session controls as root. A successful audio recovery requires both
the three services and a non-dummy output in the post-check.

Every diagnostic category—general system, sound, display, network, startup,
packages, storage, graphics, and security—has a local runbook. The app can send
only the structured finding codes, answers, and matching local runbook to the
configured AI. Each provider request still has its own explicit data-use
consent. The proposal must pass the local allowlist and independent hash-bound
risk review before the page displays the exact fixed actions. A plan containing
only another inspection is not presented as a repair. If no evidence-backed
write action exists—especially
for disk-health, graphics-hardware, active-compromise, application-specific,
or ambiguous failures—the wizard gives a manual handoff instead of pretending
that AI changed the system.

User-session changes do not ask for an administrator password. On an installed
system, the privileged D-Bus service requests one exact Polkit action; the Meo
operating-system authentication agent owns password entry. The repair app, its
logs, the D-Bus method, and the AI path never receive the password. The physical
Live repair image has locked accounts,
so it does not pretend that a reusable default password is security: its
image-only rule authorizes only the active local `live` session and the same
four exact Live wrapper paths, only when `pkexec` targets root. The wrappers
accept no caller-supplied arguments, and both the Live policy and rule are never
installed onto the target system.

## Knowledge and AI policy

Production diagnosis uses the versioned files in `knowledge/`, installed at
`/usr/share/meoarch-repair/knowledge`. This local pack is the authoritative,
offline, release-matched source for prompts and runbooks. A website may publish
the same documentation and signed updates, but live web pages must not silently
change repair behavior. A Codex skill is useful for maintainers who author and
review runbooks; it is not the runtime knowledge store for end users.

The AI stage is optional. It receives the bounded problem statement, structured
finding codes, and the matching local runbook—not raw terminal output. Local
code validates the exact response schema and requires every selected action to
be supported by the selected category and findings. Insufficient evidence must
produce explanation/manual next steps with an empty action list.

The component acceptance run includes a loopback-only AI-flow smoke test. It
exercises explicit consent for both requests, a schema-valid proposal, an
independent review bound to the proposal SHA-256, the final confirmation, and a
typed write-action dispatch. Bubblewrap replaces the diagnostic and redirects
the system-bus address to an isolated D-Bus session that exports only the typed
`RestartNetworkManager` fixture; the action writes only a temporary marker.
The fake provider uses loopback only,
and the test never changes host services. Real-provider quality, privileged
repairs, hardware, and a booted ISO remain separate runtime acceptance
boundaries.
