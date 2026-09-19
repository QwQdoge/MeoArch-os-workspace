import json
import importlib.util
import os
import shutil
import subprocess
import tarfile
import tempfile
import time
import unittest
from unittest import mock
from io import BytesIO
from pathlib import Path
import sys


ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / "backend"))
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

    def test_missing_selected_package_fails(self):
        result = self._run_preflight(*self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable"]))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("meo-desktop", result.stderr)

    def test_missing_icon_studio_blocks_a_settings_package_plan(self):
        plan = json.loads(self.plan.read_text())
        plan["package"]["packages"] = ["meo-settings", "meo-icon-studio"]
        self.plan.write_text(json.dumps(plan))
        result = self._run_preflight(*self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable", "meo-settings"]
        ))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("meo-icon-studio", result.stderr)

    def test_expired_signing_key_fails_even_with_good_signature(self):
        past = str(int(time.time()) - 2 * 24 * 60 * 60)
        identity = "Expired test key <expired@example.invalid>"
        self._run_gpg("--faked-system-time", past, "--quick-generate-key", identity, "ed25519", "sign", "1d")
        listing = self._run_gpg("--with-colons", "--list-keys", identity).stdout
        fingerprint = next(line.split(":")[9] for line in listing.splitlines() if line.startswith("fpr:"))
        exported = subprocess.run(["gpg", "--homedir", self.gpg_home, "--batch", "--export", fingerprint],
                                  check=True, capture_output=True)
        (self.bootstrap / "meo.gpg").write_bytes(exported.stdout)
        (self.bootstrap / "meo-trusted").write_text(f"{fingerprint}:6:\n")
        database, signature = self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable", "meo-desktop"])
        self._run_gpg("--faked-system-time", past, "--yes", "--detach-sign", "--local-user", fingerprint,
                      "--output", str(signature), str(database))
        result = self._run_preflight(database, signature)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expired", result.stderr)

    def test_missing_iso_keyring_file_fails_before_network_access(self):
        (self.bootstrap / "meo-revoked").unlink()
        result = subprocess.run(
            [str(PREFLIGHT), str(self.plan), str(self.bootstrap)],
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 3)
        self.assertIn("meo-revoked", result.stderr)

    def test_generated_stable_profiles_pass_with_complete_signed_metadata(self):
        for profile in ("recommended", "minimal"):
            with self.subTest(profile=profile):
                selections = json.loads((ROOT / "data/default_selections.json").read_text())
                selections["software"].update(profile=profile, channel="stable")
                selection_path = self.root / "selections.json"
                selection_path.write_text(json.dumps(selections))
                state = self.root / profile
                spec = importlib.util.spec_from_file_location("generate_config_preflight_test", ROOT / "backend/generate-config.py")
                generator = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(generator)
                # Only disk identity is stubbed; run the actual generator entry
                # point/catalog resolver without exposing a host block device.
                arguments = ["generate-config.py", "--data-dir", str(ROOT / "data"),
                             "--state-dir", str(state), "--selections", str(selection_path)]
                with mock.patch.object(generator, "verify_selected_disk_identity", return_value=(True, "")), \
                     mock.patch.object(sys, "argv", arguments):
                    generator.main()
                self.plan = state / "generated/install-plan.json"
                plan = json.loads(self.plan.read_text())
                names = [*plan["repository"]["bootstrapPackages"], plan["repository"]["channelPackage"],
                         *plan["package"]["packages"]]
                self.assertFalse(json.loads((state / "config_manifest.json").read_text())["realInstallReady"])
                result = self._run_preflight(*self._write_signed_database(names))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("Repository preflight = PASS", result.stdout)

    def test_invalid_plan_fails_before_network_access(self):
        original = json.loads(self.plan.read_text())
        for field, value in (("channel", "unknown"), ("repositories", ["meo-beta", "meo"]),
                             ("bootstrapPackages", []), ("channelPackage", "meo-channel-beta")):
            with self.subTest(field=field):
                plan = json.loads(json.dumps(original))
                plan["repository"][field] = value
                self.plan.write_text(json.dumps(plan))
                result = self._run_preflight(self.root / "missing-db", self.root / "missing-sig")
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertIn("Invalid Meo install plan", result.stderr)
                self.assertNotIn("cannot stat", result.stderr)

    def test_malformed_json_fails_closed(self):
        self.plan.write_text("{")
        result = self._run_preflight(self.root / "missing-db", self.root / "missing-sig")
        self.assertEqual(result.returncode, 2)

    def test_internal_separator_cannot_be_used_as_package_name(self):
        plan = json.loads(self.plan.read_text())
        plan["package"]["packages"] = ["--bootstrap--"]
        self.plan.write_text(json.dumps(plan))
        result = self._run_preflight(self.root / "missing-db", self.root / "missing-sig")
        self.assertEqual(result.returncode, 2)

    def test_unreachable_repository_fails(self):
        result = self._run_preflight(self.root / "missing-db", self.root / "missing-sig")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Repository preflight = PASS", result.stdout)

    def test_key_in_keyring_but_not_trusted_cannot_sign_repository(self):
        (self.bootstrap / "meo-trusted").write_text(f"{'A' * 40}:6:\n")
        result = self._run_preflight(*self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable", "meo-desktop"]))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("untrusted", result.stderr)

    def test_revoked_trust_root_fails(self):
        (self.bootstrap / "meo-revoked").write_text(f"{self.fingerprint}\n")
        result = self._run_preflight(*self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-stable", "meo-desktop"]))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("revoked", result.stderr)

    def test_beta_requires_bootstrap_packages_in_stable_not_only_overlay(self):
        plan = json.loads(self.plan.read_text())
        plan["repository"].update(channel="beta", repositories=["meo-beta", "meo"],
                                  channelPackage="meo-channel-beta")
        self.plan.write_text(json.dumps(plan))
        database, signature = self._write_signed_database(["meo-desktop"])
        stable_database, stable_signature = self.root / "stable.db", self.root / "stable.db.sig"
        shutil.copyfile(database, stable_database)
        shutil.copyfile(signature, stable_signature)
        database, signature = self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-beta", "meo-desktop"])
        curl = self.bin_dir / "curl"
        curl.write_text(curl.read_text().replace(
            'case "$url" in *.sig)',
            f'case "$url" in */meo.db.sig) cp "{stable_signature}" "$output" ;; '
            f'*/meo.db) cp "{stable_database}" "$output" ;; *.sig)'))
        result = self._run_preflight(database, signature)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("absent from signed Stable metadata", result.stderr)

    def test_beta_order_passes_when_stable_also_supplies_bootstrap(self):
        plan = json.loads(self.plan.read_text())
        plan["repository"].update(channel="beta", repositories=["meo-beta", "meo"],
                                  channelPackage="meo-channel-beta")
        self.plan.write_text(json.dumps(plan))
        result = self._run_preflight(*self._write_signed_database(
            ["meo-keyring", "meo-mirrorlist", "meo-channel-beta", "meo-desktop"]))
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
