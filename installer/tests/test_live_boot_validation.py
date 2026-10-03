import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT.parent / "meoarch-os"
LIVE_VERIFY = PROFILE / "airootfs/usr/local/bin/meoarch-live-verify"
VERIFY_UNIT = PROFILE / "airootfs/etc/systemd/system/meoarch-live-verify.service"
INSTALLER_UNIT = PROFILE / "airootfs/etc/systemd/system/meoarch-installer.service"


class LiveBootValidationTests(unittest.TestCase):
    def test_live_verifier_is_bundled_and_executable_by_contract(self):
        script = LIVE_VERIFY.read_text(encoding="utf-8")
        self.assertTrue(script.startswith("#!/usr/bin/env bash"))
        for required in (
            "/usr/local/bin/meoarch-installer-kiosk",
            "/opt/meoarch-installer/bin/meoarch-installer-app",
            "/opt/meoarch-installer/backend/verify-target.py",
            "/usr/lib/meoarch-repair/checks/all.sh",
        ):
            self.assertIn(required, script)

    def test_boot_unit_runs_before_installer_and_has_safe_repairs(self):
        unit = VERIFY_UNIT.read_text(encoding="utf-8")
        installer = INSTALLER_UNIT.read_text(encoding="utf-8")
        self.assertIn("ExecStart=/usr/local/bin/meoarch-live-verify", unit)
        self.assertIn("WantedBy=multi-user.target", unit)
        self.assertIn("meoarch-live-verify.service", installer)
        self.assertIn("systemctl daemon-reload", LIVE_VERIFY.read_text(encoding="utf-8"))
        self.assertIn("systemctl restart NetworkManager.service", LIVE_VERIFY.read_text(encoding="utf-8"))
        self.assertIn("pacman-key --init", LIVE_VERIFY.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
