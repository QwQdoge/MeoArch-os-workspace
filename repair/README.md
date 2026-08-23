# MeoArch Quick Repair

This folder is the shared source for the installed-system troubleshooter and
the Live ISO repair entry. Both surfaces use the same controller, MeoUI QML,
fixed diagnostic scripts, action allowlist, consent dialog, plan schema, risk
review schema, plan hash, and exact confirmation phrase.

AI is optional. Read-only category checks work without an account or API key.
Local provider keys can be kept for the current process only or stored through
QtKeychain with insecure fallback disabled. MeoArch Account is an optional
broker source and never returns provider keys to this app.

The CLI only runs fixed read-only checks:

```text
meoarch-repair --cli --category=all
meoarch-repair --cli --category=network
```

Write actions are fixed scripts selected by typed IDs. On an installed system
they require Polkit authorization. In Live mode, target-aware actions require a
validated system mounted at `/mnt`. No AI response is interpreted as a command,
path, argument list, package name, or URL.
