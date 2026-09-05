#!/usr/bin/env python3
"""Verify a repository with only the ISO's public ownertrust and revocation data.

Unlike gpgv with a raw keyring, gpg checks expiry and certification trust. Never
uses the live user's GPG home, network key retrieval, or downloaded trust roots.
"""
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def verify(bootstrap: Path, signature: Path, database: Path) -> None:
    for name in ("meo.gpg", "meo-trusted", "meo-revoked"):
        path = bootstrap / name
        if path.is_symlink() or not path.is_file() or not path.stat().st_size:
            raise ValueError(f"invalid public bootstrap file: {name}")

    def lines(name):
        return [line.strip() for line in (bootstrap / name).read_text().splitlines()
                if line.strip() and not line.lstrip().startswith("#")]

    trusted = lines("meo-trusted")
    revoked = lines("meo-revoked")
    if not trusted or any(not re.fullmatch(r"[0-9A-Fa-f]{40}:[56]:", line) for line in trusted):
        raise ValueError("invalid bootstrap ownertrust metadata")
    if any(not re.fullmatch(r"[0-9A-Fa-f]{40}", line) for line in revoked):
        raise ValueError("invalid bootstrap revoked metadata")
    revoked = {line.upper() for line in revoked}
    if revoked & {line[:40].upper() for line in trusted}:
        raise ValueError("bootstrap trust root is revoked")

    with tempfile.TemporaryDirectory(prefix="meo-verify-") as directory:
        command = ["gpg", "--homedir", directory, "--batch", "--no-options",
                   "--no-auto-key-retrieve", "--auto-key-locate", "clear"]

        def run(*arguments):
            return subprocess.run([*command, *map(str, arguments)], capture_output=True, text=True,
                                  env=dict(os.environ, LC_ALL="C"))

        packets = run("--list-packets", bootstrap / "meo.gpg")
        if packets.returncode or ":secret key packet:" in packets.stdout or ":secret sub key packet:" in packets.stdout:
            raise ValueError("bootstrap must contain public keys only")
        for arguments in (("--import", bootstrap / "meo.gpg"),
                          ("--import-ownertrust", bootstrap / "meo-trusted")):
            result = run(*arguments)
            if result.returncode:
                raise ValueError("could not import ISO public trust material")
        result = run("--status-fd", "1", "--verify", signature, database)
        records = [line.split()[1:] for line in result.stdout.splitlines()
                   if line.startswith("[GNUPG:] ")]
        invalid = {"BADSIG", "ERRSIG", "EXPSIG", "EXPKEYSIG", "REVKEYSIG", "NO_PUBKEY", "FAILURE"}
        valid = [record for record in records if record[0] == "VALIDSIG"]
        trusted_signature = any(record[0] in {"TRUST_FULLY", "TRUST_ULTIMATE"} for record in records)
        if (result.returncode or len(valid) != 1 or not trusted_signature
                or any(record[0] in invalid for record in records)):
            raise ValueError("repository signature is invalid, expired, or untrusted")
        # VALIDSIG identifies the signing key and, for a subkey, its primary key.
        if {valid[0][1].upper(), valid[0][-1].upper()} & revoked:
            raise ValueError("repository signature uses a revoked key")


if __name__ == "__main__":
    try:
        verify(*(Path(value).resolve() for value in sys.argv[1:]))
    except (ValueError, OSError) as error:
        raise SystemExit(f"Meo repository verification failed: {error}")
