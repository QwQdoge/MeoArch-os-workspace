"""Verify that systemd can activate the installed first-login Welcome."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
GENERATOR = Path("/usr/lib/systemd/user-generators/systemd-xdg-autostart-generator")


@unittest.skipUnless(GENERATOR.is_file(), "requires systemd XDG autostart generator")
class FirstLoginAutostartTests(unittest.TestCase):
    def test_welcome_generates_a_session_unit(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            autostart = root / "config/autostart"
            autostart.mkdir(parents=True)
            entry = ROOT / "installer/data/autostart/org.meo.welcome.desktop"
            (autostart / entry.name).write_text(entry.read_text())
            binary = root / "bin/meo-welcome"
            binary.parent.mkdir()
            binary.write_text("#!/bin/sh\nexit 0\n")
            binary.chmod(0o755)
            outputs = [root / name for name in ("normal", "early", "late")]
            for output in outputs:
                output.mkdir()
            environment = dict(os.environ, HOME=str(root),
                               XDG_CONFIG_HOME=str(root / "config"),
                               XDG_CONFIG_DIRS=str(root / "empty"),
                               PATH=str(binary.parent) + os.pathsep + os.defpath)
            result = subprocess.run([str(GENERATOR), *map(str, outputs)],
                                    env=environment, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            unit = outputs[2] / "app-org.meo.welcome@autostart.service"
            self.assertTrue(unit.is_file(), result.stderr)
            self.assertIn("meo-welcome", unit.read_text())
            enabled = outputs[2] / "xdg-desktop-autostart.target.wants" / unit.name
            self.assertTrue(enabled.is_symlink())
            self.assertEqual(enabled.resolve(), unit.resolve())
