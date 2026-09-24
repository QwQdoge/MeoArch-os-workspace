# ISO Build

## Prerequisites

Use an Arch-family host with `archiso`, CMake, Ninja, Qt 6 development files,
`xorriso`, `squashfs-tools` and normal network access to Arch package mirrors.
Current ArchISO supports rootless builds when unprivileged user namespaces are
enabled.

## Build

```bash
./scripts/build-iso.sh
```

The direct build defaults to the workspace-adjacent output tree
`$MEO_OUTPUT_ROOT/meo-arch-os-workspace/packages/iso/` when
`MEO_OUTPUT_ROOT` is set; otherwise the scripts derive a portable output root
next to the checkout. For an acceptance candidate, use a named UTC run
directory so the ISO, its checksum, and the matching validation record can be
identified together:

```bash
run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-candidate"
MEOARCH_RUN_ID="${run_id}" ./scripts/acceptance/30-build-iso.sh
```

That wrapper writes the candidate ISO under
`$MEO_OUTPUT_ROOT/meo-arch-os-workspace/packages/iso/acceptance/<run-id>/`
when the global output root is configured, and its build log, status, size,
SHA-256, and ISO path under the matching `validation/<run-id>/iso/` directory.
It does not clean the existing reproducible `build/archiso` workspace.

For a direct build, explicitly select the same package destination rather than
placing a release under the repository:

```bash
run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-manual-iso"
./scripts/build-iso.sh --output \
  "${MEO_OUTPUT_ROOT}/meo-arch-os-workspace/packages/iso/${run_id}"
```

Force a clean component/profile/work rebuild:

```bash
./scripts/build-iso.sh --clean
```

`--clean` removes only reproducible files below `build/archiso`. Existing ISO
files are never silently deleted. If mkarchiso would reuse or overwrite an
existing candidate, move that candidate aside or select another output
directory.

The script stages the profile below `build/archiso/profile`; it does not mutate
the authoritative `meoarch-os` source tree. Direct-build logs and staging
provenance are retained under
`$MEO_OUTPUT_ROOT/meo-arch-os-workspace/validation/<UTC-run-id>-iso-build/logs/`
when the global output root is configured. The acceptance wrapper additionally
retains the run-specific hash/status evidence described above.

## Output

On success the script prints the absolute ISO path, byte size and SHA-256.
Any component build, package resolution or mkarchiso failure stops the build
and leaves its log intact.

## Troubleshooting

- `Missing required tool`: install the named host build dependency.
- Package resolution/download failure: verify the configured mirrors and rerun;
  it is not an ISO success.
- User namespace failure: enable unprivileged user namespaces or run the same
  script in a controlled Arch build VM with root privileges.
- Existing output name: preserve or move the old ISO, or use `--output`.

Use `./scripts/build-iso.sh --help` or
`./scripts/acceptance/30-build-iso.sh --help` to inspect the non-destructive
command interface. Building an ISO remains separate from live-boot and
installed-system acceptance.
