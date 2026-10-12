#!/usr/bin/env python3
"""Fail closed when the Live image separates Meo AI from its Account UX."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGE_LIST = ROOT / "meoarch-os" / "packages.x86_64"


def package_names() -> set[str]:
    packages: set[str] = set()
    for raw in PACKAGE_LIST.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        packages.add(line.split()[0])
    return packages


def main() -> None:
    packages = package_names()
    ai_stack = {"meo-account", "meo-settings", "meo-ai"}
    present = ai_stack & packages
    if present and present != ai_stack:
        missing = ", ".join(sorted(ai_stack - packages))
        raise SystemExit(
            "Live AI/account closure is incomplete; missing required package(s): " + missing
        )
    if "meo-ai" not in packages:
        raise SystemExit("The recommended Live image must include meo-ai")


if __name__ == "__main__":
    main()
