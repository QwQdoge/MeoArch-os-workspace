import importlib.util
import os
from pathlib import Path
import tempfile
import unittest

BACKEND = Path(__file__).resolve().parents[1] / "backend"
spec = importlib.util.spec_from_file_location("verify_target", BACKEND / "verify-target.py")
target = importlib.util.module_from_spec(spec)
spec.loader.exec_module(target)


class TargetValidationTests(unittest.TestCase):
    def verify_fixture(self, root):
        target.verify(root, expected_system_owner=(os.getuid(), os.getgid()))

    def populate(self, root):
        (root / "var").mkdir(exist_ok=True)
        files = (*target.REQUIRED_FILES, *target.REQUIRED_EXECUTABLES,
                 "boot/EFI/GRUB/grubx64.efi", "usr/lib/systemd/system/plasmalogin.service",
                 "usr/lib/systemd/system/NetworkManager.service")
        for name in files:
            path = root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            content = {
                "etc/os-release": "ID=meoarch\n",
                "etc/xdg/meo-shellrc": "[Panels]\nDockImplementation=native\n",
                "usr/share/plasma/look-and-feel/org.meo.desktop/contents/layouts/org.kde.plasma.desktop-layout.js": (
                    'var bottomPanel = new Panel\n'
                    'bottomPanel.addWidget("org.kde.plasma.icontasks")\n'
                ),
                "usr/lib/systemd/zram-generator.conf.d/50-meo-desktop.conf": (
                    "[zram0]\nzram-size = min(ram / 2, 8192)\nswap-priority = 100\n"
                ),
                "etc/system76-scheduler/process-scheduler/meo-cachyos.kdl": (
                    "// Unique process names: 15806\nassignments {\n foreground { dolphin }\n}\n"
                ),
                "usr/lib/systemd/system-preset/50-meo-responsiveness.preset": (
                    "enable com.system76.Scheduler.service\n"
                    "enable power-profiles-daemon.service\n"
                    "disable ananicy-cpp.service\n"
                    "disable preload-ng.service\n"
                    "disable prelockd.service\n"
                ),
            }.get(name, "fixture\n")
            path.write_text(content)
            if name in target.REQUIRED_EXECUTABLES:
                path.chmod(0o755)
        for link, destination in (
            ("display-manager.service", "/usr/lib/systemd/system/plasmalogin.service"),
            ("multi-user.target.wants/NetworkManager.service", "/usr/lib/systemd/system/NetworkManager.service"),
            ("multi-user.target.wants/com.system76.Scheduler.service", "/usr/lib/systemd/system/com.system76.Scheduler.service"),
            ("multi-user.target.wants/power-profiles-daemon.service", "/usr/lib/systemd/system/power-profiles-daemon.service"),
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
            self.verify_fixture(root)

    def test_every_required_payload_and_enabled_service_fails_when_missing(self):
        for missing in (*target.REQUIRED_FILES, *target.REQUIRED_EXECUTABLES,
                        "boot/EFI/GRUB/grubx64.efi",
                        *(f"etc/systemd/system/{service}" for service in target.REQUIRED_ENABLED_SERVICES)):
            with self.subTest(missing=missing), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.populate(root)
                (root / missing).unlink()
                with self.assertRaises(ValueError):
                    self.verify_fixture(root)

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
        self.assertLess(script.index('systemd-tmpfiles --create --remove'),
                        script.index('/backend/verify-target.py'))
        self.assertIn('pacman -Syu --needed --noconfirm', script)

    def test_target_rejects_unsafe_top_level_system_ownership(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.populate(root)
            unexpected = (os.getuid() + 1, os.getgid() + 1)
            with self.assertRaisesRegex(ValueError, "unsafe ownership"):
                target.verify(root, expected_system_owner=unexpected)

    def test_target_contract_requires_the_independent_first_login_flow(self):
        self.assertIn("usr/bin/meo-welcome", target.REQUIRED_EXECUTABLES)
        self.assertIn("etc/xdg/autostart/org.meo.welcome.desktop", target.REQUIRED_FILES)
        self.assertIn("usr/share/applications/org.meo.welcome.desktop", target.REQUIRED_FILES)

    def test_target_contract_persists_the_calendar_display_preference(self):
        self.assertIn("etc/xdg/MeoArch/Calendar.ini", target.REQUIRED_FILES)

    def test_target_contract_requires_the_responsiveness_stack(self):
        for path in (
            "etc/gamemode.ini",
            "etc/system76-scheduler/process-scheduler/meo-cachyos.kdl",
            "usr/lib/systemd/zram-generator.conf.d/50-meo-desktop.conf",
            "usr/lib/systemd/system-preset/50-meo-responsiveness.preset",
        ):
            self.assertIn(path, target.REQUIRED_FILES)
        self.assertIn("usr/bin/system76-scheduler", target.REQUIRED_EXECUTABLES)
        self.assertIn("multi-user.target.wants/com.system76.Scheduler.service",
                      target.REQUIRED_ENABLED_SERVICES)

    def test_target_rejects_enabled_ananicy_daemon(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.populate(root)
            conflict = root / "etc/systemd/system/multi-user.target.wants/ananicy-cpp.service"
            conflict.symlink_to("/usr/lib/systemd/system/ananicy-cpp.service")
            with self.assertRaisesRegex(ValueError, "conflicting target service"):
                self.verify_fixture(root)

    def test_target_rejects_retired_standalone_dock_payload(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.populate(root)
            legacy = root / "etc/xdg/autostart/org.meo.dock.desktop"
            legacy.parent.mkdir(parents=True, exist_ok=True)
            legacy.write_text("[Desktop Entry]\n")
            with self.assertRaisesRegex(ValueError, "retired standalone Dock payload"):
                self.verify_fixture(root)

    def test_target_requires_native_plasma_dock_contract(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.populate(root)
            (root / "etc/xdg/meo-shellrc").write_text("[Panels]\nDockImplementation=standalone\n")
            with self.assertRaisesRegex(ValueError, "native Plasma Dock"):
                self.verify_fixture(root)

    def test_target_rejects_unbounded_zram_profile(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.populate(root)
            config = root / "usr/lib/systemd/zram-generator.conf.d/50-meo-desktop.conf"
            config.write_text("[zram0]\nzram-size = ram\nswap-priority = 100\n")
            with self.assertRaisesRegex(ValueError, "bounded Meo profile"):
                self.verify_fixture(root)
