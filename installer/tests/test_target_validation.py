import importlib.util
from pathlib import Path
import tempfile
import unittest

BACKEND = Path(__file__).resolve().parents[1] / "backend"
spec = importlib.util.spec_from_file_location("verify_target", BACKEND / "verify-target.py")
target = importlib.util.module_from_spec(spec)
spec.loader.exec_module(target)


class TargetValidationTests(unittest.TestCase):
    def populate(self, root):
        files = (*target.REQUIRED_FILES, *target.REQUIRED_EXECUTABLES,
                 "boot/EFI/GRUB/grubx64.efi", "usr/lib/systemd/system/sddm.service",
                 "usr/lib/systemd/system/NetworkManager.service")
        for name in files:
            path = root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("ID=meoarch\n" if name == "etc/os-release" else "fixture\n")
            if name in target.REQUIRED_EXECUTABLES:
                path.chmod(0o755)
        for link, destination in (
            ("display-manager.service", "/usr/lib/systemd/system/sddm.service"),
            ("multi-user.target.wants/NetworkManager.service", "/usr/lib/systemd/system/NetworkManager.service"),
        ):
            path = root / "etc/systemd/system" / link
            path.parent.mkdir(parents=True, exist_ok=True)
            path.symlink_to(destination)

    def test_minimal_requires_only_installed_payload_not_live_source_or_extra_apps(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.populate(root)
            self.assertFalse((root / "opt/meo-desktop").exists())
            self.assertFalse((root / "usr/bin/meoarch-repair").exists())
            target.verify(root)

    def test_every_required_payload_and_enabled_service_fails_when_missing(self):
        for missing in (*target.REQUIRED_FILES, *target.REQUIRED_EXECUTABLES,
                        "boot/EFI/GRUB/grubx64.efi", "etc/systemd/system/display-manager.service",
                        "etc/systemd/system/multi-user.target.wants/NetworkManager.service"):
            with self.subTest(missing=missing), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.populate(root)
                (root / missing).unlink()
                with self.assertRaises(ValueError):
                    target.verify(root)

    def test_absolute_link_never_uses_host_payload(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "command").symlink_to("/usr/bin/python3")
            self.assertEqual(target.target_path(root, "command"), root / "usr/bin/python3")
            self.assertFalse(target.target_path(root, "command").exists())
            (root / "cycle").symlink_to("cycle")
            with self.assertRaises(ValueError):
                target.target_path(root, "cycle")

    def test_false_complete_cannot_skip_shared_target_validator(self):
        script = (BACKEND / "run-archinstall.sh").read_text()
        self.assertLess(script.index('/backend/verify-target.py'), script.index('progress "complete" 100'))
