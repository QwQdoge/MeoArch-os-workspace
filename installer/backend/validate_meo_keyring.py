#!/usr/bin/env python3
"""Fail-closed validation for the public ISO Meo pacman keyring payload."""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path


PAYLOAD = ("meo.gpg", "meo-trusted", "meo-revoked")
FINGERPRINT = re.compile(r"^[A-F0-9]{40}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
TRUSTED = re.compile(r"^([A-F0-9]{40}):4:$")


def fail(message: str) -> None:
    raise SystemExit(f"ISO keyring bootstrap validation failed: {message}")


def public_fingerprints(keyring: Path) -> set[str]:
    try:
        result = subprocess.run(
            ("gpg", "--batch", "--no-default-keyring", "--keyring", str(keyring), "--with-colons", "--list-keys"),
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError as error:
        fail(f"gpg is required to inspect meo.gpg: {error}")
    if result.returncode != 0:
        fail("gpg could not read meo.gpg")
    return {
        fields[9].upper()
        for fields in (line.split(":") for line in result.stdout.splitlines())
        if len(fields) > 9 and fields[0] == "fpr" and FINGERPRINT.fullmatch(fields[9].upper())
    }


def trusted_fingerprints(path: Path) -> set[str]:
    values: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip().upper()
        if not line:
            continue
        match = TRUSTED.fullmatch(line)
        if not match:
            fail("meo-trusted must contain full fingerprints with full ownertrust")
        values.add(match.group(1))
    if not values:
        fail("meo-trusted must be non-empty")
    return values


def revoked_fingerprints(path: Path) -> set[str]:
    values = {line.strip().upper() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()}
    if not values or any(not FINGERPRINT.fullmatch(value) for value in values):
        fail("meo-revoked must be a non-empty list of full fingerprints")
    return values


def validate(root: Path) -> None:
    missing = [name for name in PAYLOAD if not (root / name).is_file() or not (root / name).stat().st_size]
    if missing:
        fail("missing/non-empty " + ", ".join(missing))
    metadata_path = root / "meo-keyring.json"
    if not metadata_path.is_file() or not metadata_path.stat().st_size:
        fail("missing/non-empty meo-keyring.json")
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"invalid meo-keyring.json: {error}")
    if not isinstance(metadata, dict) or metadata.get("schemaVersion") != 1:
        fail("meo-keyring.json requires schemaVersion 1")
    if not isinstance(metadata.get("version"), str) or not metadata["version"]:
        fail("meo-keyring.json requires a version")
    fingerprints = metadata.get("fingerprints")
    if not isinstance(fingerprints, list) or not fingerprints:
        fail("meo-keyring.json has invalid reviewed fingerprints")
    if any(not isinstance(value, str) or not FINGERPRINT.fullmatch(value) for value in fingerprints):
        fail("meo-keyring.json has invalid reviewed fingerprints")
    if len(set(fingerprints)) != len(fingerprints):
        fail("meo-keyring.json has invalid reviewed fingerprints")
    hashes = metadata.get("payloadSha256")
    if not isinstance(hashes, dict) or set(hashes) != set(PAYLOAD):
        fail("meo-keyring.json has an invalid payload hash set")
    for name in PAYLOAD:
        actual = hashlib.sha256((root / name).read_bytes()).hexdigest()
        if not isinstance(hashes[name], str) or not SHA256.fullmatch(hashes[name]) or hashes[name] != actual:
            fail(f"payload SHA-256 mismatch: {name}")
    expected = set(fingerprints)
    if not expected <= public_fingerprints(root / "meo.gpg"):
        fail("meo.gpg does not contain every reviewed fingerprint")
    if not expected <= trusted_fingerprints(root / "meo-trusted"):
        fail("meo-trusted does not fully trust every reviewed fingerprint")
    if expected & revoked_fingerprints(root / "meo-revoked"):
        fail("a reviewed signing fingerprint is listed as revoked")


if __name__ == "__main__":
    try:
        validate(Path(sys.argv[1] if len(sys.argv) > 1 else "/opt/meoarch-installer/bootstrap"))
    except OSError as error:
        fail(str(error))
