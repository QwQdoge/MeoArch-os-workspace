import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

BACKEND = Path(__file__).resolve().parents[1] / "backend"
spec = importlib.util.spec_from_file_location("plymouth_hooks", BACKEND / "configure-plymouth-hooks.py")
hooks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hooks)


class TargetBootTests(unittest.TestCase):
    def test_udev_and_systemd_arrays_and_idempotency(self):
        for manager in ("udev", "systemd"):
            source = f"# plymouth comment is not a hook\nHOOKS=(base '{manager}'\n autodetect modconf block filesystems fsck)\n"
            result = hooks.configure(source)
            self.assertIn(f"HOOKS=(base {manager} plymouth autodetect", result)
            self.assertEqual(hooks.configure(result), result)

    def test_ambiguous_or_dynamic_hook_configuration_fails(self):
        for text in ("# no hooks", "HOOKS=(base filesystems)", "HOOKS=(base udev systemd)",
                     "HOOKS=(base udev ${EXTRA})", "HOOKS=(base udev)\nHOOKS=(base udev)"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                hooks.configure(text)

    def run_target(self, failure=0, omit_asset=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target, runtime, generated, commands = [root / name for name in ("target", "runtime", "generated", "commands")]
            for path in (target / "etc", target / "usr/bin", target / "usr/share/meo-desktop", generated, commands):
                path.mkdir(parents=True, exist_ok=True)
            outside = root / "host-os-release"
            outside.write_text("HOST MUST REMAIN UNCHANGED\n")
            (target / "etc/os-release").symlink_to(outside)
            (target / "usr/share/meo-desktop/os-release").write_text("ID=meoarch\n")
            (target / "etc/mkinitcpio.conf").write_text("HOOKS=(base systemd autodetect block filesystems fsck)\n")
            (target / "usr/bin/mkinitcpio").touch(mode=0o755)
            theme = runtime / "share/plymouth/themes/meoarch"
            theme.mkdir(parents=True)
            for filename in ("meoarch.plymouth", "meoarch.script", "background.png", "logo.png", "spinner.png", "warning.png", "progress_box.png", "progress_bar.png"):
                if not (omit_asset and filename == "logo.png"):
                    (theme / filename).write_bytes(b"fixture")
            (generated / "target-customizations.json").write_text(json.dumps({
                "username": "tester", "fullName": "", "automaticLogin": False,
                "sddmSession": "plasma.desktop", "firewall": False,
                "swap": {"mode": "none", "fileSizeMiB": 0},
            }))
            (commands / "arch-chroot").write_text(
                '#!/bin/sh\nprintf "%s\\n" "$*" >>"$TEST_CALLS"\n'
                'case "$2" in */mkinitcpio) exit "$TEST_FAILURE" ;; */lsinitcpio) echo usr/bin/plymouthd ;; *) exit 99 ;; esac\n')
            (commands / "ldconfig").write_text("#!/bin/sh\nexit 0\n")
            for command in commands.iterdir():
                command.chmod(0o755)
            result = subprocess.run(["bash", BACKEND / "apply-target-customizations.sh", target, "/unused-source", generated],
                                    env=dict(os.environ, PATH=f"{commands}:{os.environ['PATH']}", MEOARCH_PACKAGE_MANAGED="1",
                                             MEOARCH_RUNTIME_SOURCE=str(runtime), TEST_FAILURE=str(failure), TEST_CALLS=str(root / "calls")),
                                    capture_output=True, text=True)
            self.assertEqual(outside.read_text(), "HOST MUST REMAIN UNCHANGED\n")
            self.assertEqual((target / "etc/os-release").read_text(), "ID=meoarch\n")
            self.assertFalse((target / "etc/os-release").is_symlink())
            calls = (root / "calls").read_text() if (root / "calls").exists() else ""
            return result, calls

    def test_package_managed_target_needs_no_desktop_source_copy(self):
        result, calls = self.run_target()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("/usr/bin/mkinitcpio -P", calls)
        self.assertIn("/usr/bin/lsinitcpio /boot/initramfs-linux.img", calls)

    def test_initramfs_failure_is_not_reported_as_success(self):
        result, calls = self.run_target(failure=17)
        self.assertEqual(result.returncode, 17, result.stderr)
        self.assertNotIn("lsinitcpio", calls)
        self.assertNotIn("customizations applied", result.stdout)

    def test_incomplete_live_theme_fails_before_initramfs(self):
        result, calls = self.run_target(omit_asset=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("logo.png", result.stderr)
        self.assertEqual(calls, "")
