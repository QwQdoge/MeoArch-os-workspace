"""Exercise acceptance artifact selection without invoking mkarchiso."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(shutil.which("sha256sum") and subprocess.run(
    ["stat", "--version"], capture_output=True).returncode == 0,
    "acceptance ISO evidence uses GNU stat and sha256sum")
class AcceptanceIsoTests(unittest.TestCase):
    def run_fixture(self, report):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            scripts = root / "scripts"
            (scripts / "acceptance").mkdir(parents=True)
            script = scripts / "acceptance/30-build-iso.sh"
            shutil.copyfile(ROOT / "scripts/acceptance/30-build-iso.sh", script)
            output = root / "output"
            output.mkdir()
            (output / "stale.iso").write_bytes(b"previous build")
            candidate = output / "current.iso"
            candidate.write_bytes(b"current build")
            builder = scripts / "build-iso.sh"
            builder.write_text("#!/usr/bin/env bash\nprintf '%s\\n' " +
                               repr(report(str(candidate), str(root))) + "\n")
            builder.chmod(0o755)
            evidence = root / "evidence"
            env = dict(os.environ, MEOARCH_RUN_DIR=str(evidence),
                       MEOARCH_ISO_OUTPUT_DIR=str(output))
            result = subprocess.run(["bash", str(script)], env=env,
                                    capture_output=True, text=True)
            selected = evidence / "iso/iso-path.txt"
            return result.returncode, selected.read_text().strip() if selected.exists() else "", str(candidate)

    def test_reused_output_selects_this_build_not_stale_iso(self):
        code, selected, candidate = self.run_fixture(lambda candidate, root: "ISO: " + candidate)
        self.assertEqual(code, 0)
        self.assertEqual(selected, candidate)

    def test_missing_build_report_does_not_accept_old_iso(self):
        code, selected, _ = self.run_fixture(lambda candidate, root: "build failed to emit an artifact")
        self.assertNotEqual(code, 0)
        self.assertEqual(selected, "")

    def test_report_outside_requested_output_is_rejected(self):
        code, selected, _ = self.run_fixture(lambda candidate, root: "ISO: " + root + "/outside.iso")
        self.assertNotEqual(code, 0)
        self.assertEqual(selected, "")
