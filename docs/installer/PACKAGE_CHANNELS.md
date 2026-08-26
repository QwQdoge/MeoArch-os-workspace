# Package-managed MeoArch installation

The Installer does not own an update-channel preference. It converts GUI, CLI,
and non-interactive input into the same schema-v2 `InstallConfig` and
`InstallPlan`; after installation, pacman's resolved repository order is the
source of truth.

`stable` installs `meo-keyring`, `meo-mirrorlist`, and
`meo-channel-stable`, which owns an Include-backed `[meo]` entry. `beta`
installs the same trust and mirror packages plus `meo-channel-beta`, which
owns `[meo-beta]` before `[meo]`. The beta repository is a sparse overlay;
stable remains the fallback.

The target bootstrap first installs the public Meo keyring material carried by
the ISO, initializes the target keyring, runs `pacman-key --populate meo`, and
only then installs signed Meo packages. Repository fragments are staged and
restored on failure. There is no first transaction that installs `meo-desktop`
before the keyring.

The current ISO is online-install only. Preflight validates `x86_64`, downloads
and verifies each selected repository DB signature with the ISO public key,
and confirms every selected package is present before archinstall writes a
target. A release ISO must provide a versioned, audited
public bootstrap payload in `installer/bootstrap/`; its absence is a deliberate
fail-closed error, not an unsigned fallback.

For automation, use:

```sh
meoarch-install --config install.json --print-plan
```

The CLI is a plan/configuration frontend. The existing archinstall runner is
the only installation executor.
