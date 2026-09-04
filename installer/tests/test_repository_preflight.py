import json
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from io import BytesIO
from pathlib import Path


ROOT = Path(__file__).parents[1]
PREFLIGHT = ROOT / "backend" / "preflight-meo-repository.sh"
GPG_AVAILABLE = all(shutil.which(command) for command in ("gpg", "gpgv", "bsdtar"))


@unittest.skipUnless(GPG_AVAILABLE, "repository preflight integration test needs gpg, gpgv and bsdtar")
class RepositoryPreflightTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temporary.name)
        cls.gpg_home = cls.root / "gpg"
        cls.gpg_home.mkdir(mode=0o700)
        cls._run_gpg(
            "--quick-generate-key", "Meo preflight test <preflight@example.invalid>",
            "rsa2048", "sign", "1d",
        )
        records = cls._run_gpg("--with-colons", "--list-keys").stdout.splitlines()
        cls.fingerprint = next(record.split(":")[9] for record in records if record.startswith("fpr:"))

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    @classmethod
    def _run_gpg(cls, *arguments):
        return subprocess.run(
            ["gpg", "--homedir", cls.gpg_home, "--batch", "--pinentry-mode", "loopback", "--passphrase", "", *arguments],
            check=True,
            text=True,
            capture_output=True,
        )

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.bootstrap = self.root / "bootstrap"
        self.bootstrap.mkdir()
        exported = subprocess.run(
            ["gpg", "--homedir", self.gpg_home, "--batch", "--export", self.fingerprint],
            check=True,
            capture_output=True,
        )
        (self.bootstrap / "meo.gpg").write_bytes(exported.stdout)
        (self.bootstrap / "meo-trusted").write_text(f"{self.fingerprint}:6:\n", encoding="utf-8")
        (self.bootstrap / "meo-revoked").write_text("# no revoked keys in this disposable fixture\n", encoding="utf-8")
        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        curl = self.bin_dir / "curl"
        curl.write_text(
            "#!/usr/bin/env bash\n"
            "set -euo pipefail\n"
            "output=''\nurl=''\n"
            "while [ \"$#\" -gt 0 ]; do\n"
            "  case \"$1\" in\n"
            "    --output) output=\"$2\"; shift 2 ;;\n"
            "    *) url=\"$1\"; shift ;;\n"
            "  esac\n"
            "done\n"
            "case \"$url\" in *.sig) cp \"$FIXTURE_SIG\" \"$output\" ;; *) cp \"$FIXTURE_DB\" \"$output\" ;; esac\n",
            encoding="utf-8",
        )
        curl.chmod(0o755)
        self.plan = self.root / "install-plan.json"
        self.plan.write_text(json.dumps({
            "schemaVersion": 2,
            "architecture": "x86_64",
            "repository": {
                "channel": "stable",
                "repositories": ["meo"],
                "bootstrapPackages": ["meo-keyring", "meo-mirrorlist"],
                "channelPackage": "meo-channel-stable",
            },
            "package": {"packages": ["meo-desktop"]},
        }), encoding="utf-8")

    def tearDown(self):
        self.temporary.cleanup()

    def _write_signed_database(self, packages):
        database = self.root / "meo.db"
        with tarfile.open(database, "w:gz") as archive:
            for package in packages:
                payload = f"%NAME%\n{package}\n\n%VERSION%\n1-1\n".encode()
                entry = tarfile.TarInfo(f"{package}-1-1/desc")
                entry.size = len(payload)
                archive.addfile(entry, BytesIO(payload))
        signature = self.root / "meo.db.sig"
        self._run_gpg("--yes", "--detach-sign", "--local-user", self.fingerprint,
                      "--output", str(signature), str(database))
        return database, signature

    def _run_preflight(self, database, signature):
        environment = os.environ.copy()
        environment["PATH"] = f"{self.bin_dir}:{environment['PATH']}"
        environment["FIXTURE_DB"] = str(database)
        environment["FIXTURE_SIG"] = str(signature)
        return subprocess.run(
            [str(PREFLIGHT), str(self.plan), str(self.bootstrap)],
            text=True,
            capture_output=True,
            env=environment,
        )

    def test_complete_meo_transaction_passes_before_archinstall(self):
        database, signature = self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable", "meo-desktop"]
        )
        result = self._run_preflight(database, signature)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_bootstrap_or_channel_package_fails_before_archinstall(self):
        database, signature = self._write_signed_database(["meo-desktop"])
        result = self._run_preflight(database, signature)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("meo-keyring", result.stderr)

    def test_invalid_repository_signature_fails_before_archinstall(self):
        database, signature = self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable", "meo-desktop"]
        )
        signature.write_bytes(b"not a detached signature")
        result = self._run_preflight(database, signature)
        self.assertNotEqual(result.returncode, 0)

    def test_missing_iso_keyring_file_fails_before_network_access(self):
        (self.bootstrap / "meo-revoked").unlink()
        result = subprocess.run(
            [str(PREFLIGHT), str(self.plan), str(self.bootstrap)],
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 3)
        self.assertIn("meo-revoked", result.stderr)


if __name__ == "__main__":
    unittest.main()
