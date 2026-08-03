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

Use a separate output directory:

```bash
./scripts/build-iso.sh --output out/candidate
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
the authoritative `meoarch-os` source tree. Logs and checksums are retained
below `artifacts/build-logs/<UTC timestamp>/`.

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
