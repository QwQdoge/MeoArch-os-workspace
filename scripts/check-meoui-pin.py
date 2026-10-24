#!/usr/bin/env python3
"""Check that the MeoUI the installer/repair apps were built from is the one the
release ships.

The Live desktop gets `libmeoui`/the MeoUI QML module from the signed
`meoui-qml` package, while the Installer and Quick Repair are compiled from the
sibling MeoUI checkout. A different MeoUI commit is therefore an ABI/QML API
risk. With a release manifest (``meo-repo/manifests/<channel>/<release>.json``)
the checkout must be exactly the commit pinned for ``meoui-qml``.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

COMPONENT = "meoui-qml"


def pinned_commit(manifest: Path) -> str:
    payload = json.loads(manifest.read_text(encoding="utf-8"))
    commit = payload.get("components", {}).get(COMPONENT, {}).get("commit")
    if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise SystemExit(f"{manifest} does not pin a {COMPONENT} commit")
    return commit


def checkout_commit(source: Path) -> str:
    result = subprocess.run(["git", "-C", str(source), "rev-parse", "HEAD"],
                            capture_output=True, text=True)
    commit = result.stdout.strip()
    if result.returncode != 0 or not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise SystemExit(f"{source} is not a Git checkout; cannot verify the MeoUI pin")
    return commit


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("Usage: check-meoui-pin.py MEOUI_SOURCE RELEASE_MANIFEST", file=sys.stderr)
        return 2
    expected = pinned_commit(Path(argv[2]))
    actual = checkout_commit(Path(argv[1]))
    if expected != actual:
        print(f"MeoUI checkout {actual} differs from the release-pinned {COMPONENT} {expected}; "
              "the Installer/Repair would run against a different MeoUI than the Live desktop.",
              file=sys.stderr)
        return 1
    print(f"MeoUI pin verified: {actual}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
