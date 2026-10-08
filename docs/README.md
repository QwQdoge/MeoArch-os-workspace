# MeoArch documentation map

This directory contains product contracts, implementation notes, release evidence, and validation guidance. They do not all have the same authority.

## Authority order

When two documents appear to disagree, use the first applicable source in this order:

1. **Product identity** — `product-identity.md` owns public names, branding, and compatibility naming rules.
2. **Cross-repository product contract** — `system-experience-contract.md` owns repository responsibilities and end-to-end user flows.
3. **Owning-repository contract** — the repository that owns a capability defines its detailed runtime and security architecture. Examples: Meo Settings owns normal settings workflows; MeoKDE owns desktop/session integration; Meo Login owns login-manager behavior.
4. **Current milestone** — `CURRENT_MILESTONE.md` defines what is in scope now. A long-term contract is not automatically a current implementation task.
5. **Production readiness evidence** — `production-readiness-matrix.md` records what has actually been implemented and verified. It does not redefine architecture.
6. **Validation/build guides** — VM, ISO, build, and release-validation documents describe how evidence is collected.
7. **Historical notes and superseded design material** — useful for provenance and intent, but not authoritative when they conflict with the sources above.

## Status vocabulary

Use these terms consistently across repositories:

- **Specified** — behavior and ownership are documented.
- **Implemented** — code exists on the branch being evaluated.
- **Build-tested** — the relevant code compiles and targeted automated checks pass.
- **Session-tested** — the behavior has been exercised in a real graphical/user session.
- **VM-tested** — the end-to-end path has been exercised in a supported VM.
- **Hardware-tested** — the end-to-end path has been exercised on physical hardware.
- **Release-ready** — all release gates required for that capability are satisfied.

Do not use `implemented`, `done`, or `working` as shorthand for a stronger evidence level.

## Scope rule for agents and contributors

Long-term product documents intentionally describe more than the current milestone. During implementation or repository cleanup:

- do not implement a newly noticed feature merely because a long-term contract mentions it;
- do not restore an old experimental feature merely because a historical branch contains it;
- only add or rewrite code when it is part of the current milestone, required to integrate already-approved work, or necessary to fix a security/data-loss correctness problem discovered in that work;
- record unrelated bugs, feature ideas, architecture improvements, and technical debt instead of expanding the task automatically;
- keep experimental or future work behind an explicit separate task/branch.

This rule exists to prevent repository cleanup, review, or validation work from silently turning into unbounded feature development.

## Current architecture notes

The current Meo Session Lock direction is the Meo-owned resident lock process using the Wayland session-lock authority and PAM-backed authentication. KScreenLocker-based presentation work is historical/compatibility material unless an owning-repository contract explicitly marks a remaining compatibility role.

The login manager remains a separate lifecycle and authentication boundary even when it shares Meo visual language and presentation schema with the session lock.
