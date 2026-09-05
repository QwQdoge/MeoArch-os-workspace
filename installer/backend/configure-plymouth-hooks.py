#!/usr/bin/env python3
"""Insert Plymouth after the active device manager in a literal mkinitcpio HOOKS array."""
import re
import shlex
import sys
from pathlib import Path


def configure(text: str) -> str:
    assignments = list(re.finditer(r"^\s*HOOKS=\(([^)]*)\)", text, re.MULTILINE))
    if len(assignments) != 1:
        raise ValueError("expected exactly one literal mkinitcpio HOOKS array")
    match = assignments[0]
    hooks = shlex.split(match[1], comments=True)
    if not hooks or any(not re.fullmatch(r"[A-Za-z0-9_-]+", hook) for hook in hooks):
        raise ValueError("mkinitcpio HOOKS contains unsupported shell expansion")
    hooks = [hook for hook in hooks if hook != "plymouth"]
    managers = [hook for hook in hooks if hook in {"udev", "systemd"}]
    if len(managers) != 1:
        raise ValueError("expected one udev or systemd hook before Plymouth")
    hooks.insert(hooks.index(managers[0]) + 1, "plymouth")
    return text[:match.start()] + "HOOKS=(" + " ".join(hooks) + ")" + text[match.end():]


if __name__ == "__main__":
    path = Path(sys.argv[1])
    if path.is_symlink() or not path.is_file():
        raise SystemExit("mkinitcpio configuration must be a regular target file")
    path.write_text(configure(path.read_text()))
