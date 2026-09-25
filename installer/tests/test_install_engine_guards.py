"""Non-destructive regression tests for the destructive-install guardrails."""
import os
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).parents[1]
RUNNER = ROOT / "backend/run-archinstall.sh"
PREFLIGHT = ROOT / "backend/archinstall-preflight.sh"
ARCH_PACKAGE_PREFLIGHT = ROOT / "backend/preflight-arch-packages.sh"


class InstallEngineGuardTests(unittest.TestCase):
    def _ready_state(self, state):
        generated = state / "generated"
        generated.mkdir(mode=0o700)
        state.chmod(0o700)
        for name in ("user_configuration.json", "user_credentials.json", "install-plan.json"):
            (generated / name).write_text("{}\n", encoding="utf-8")
            (generated / name).chmod(0o600)
        manifest = state / "config_manifest.json"
        manifest.write_text(json.dumps({"schemaVersion": 2, "realInstallReady": True}), encoding="utf-8")
        manifest.chmod(0o600)
        (state / "preflight_status.json").write_text(json.dumps({
            "state": "complete", "manifestSha256": hashlib.sha256(manifest.read_bytes()).hexdigest(),
        }), encoding="utf-8")
        (state / "preflight_status.json").chmod(0o600)
        (state / "summary_confirmed").write_text("confirmed\n", encoding="utf-8")
        (state / "summary_confirmed").chmod(0o600)
        return generated

    def test_early_runner_failure_removes_all_credential_handoffs(self):
        """No Archinstall invocation: the missing confirmation stops before disk work."""
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory)
            generated = state / "generated"
            generated.mkdir(mode=0o700)
            state.chmod(0o700)
            credentials = generated / "user_credentials.json"
            handoff = generated / "network-handoff.nmconnection"
            credentials.write_text('{"users": [{"enc_password": "hash"}]}\n', encoding="utf-8")
            handoff.write_text("super-secret-network-material\n", encoding="utf-8")
            credentials.chmod(0o600)
            handoff.chmod(0o600)
            result = subprocess.run(
                ["bash", RUNNER], text=True, capture_output=True,
                env=dict(os.environ, MEOARCH_INSTALLER_STATE_DIR=str(state)),
            )
            self.assertEqual(result.returncode, 3, result.stderr)
            self.assertFalse(credentials.exists())
            self.assertFalse(handoff.exists())
            self.assertNotIn("super-secret-network-material", result.stdout + result.stderr)

    def test_runner_keeps_a_one_shot_lock_and_terminal_complete_contract(self):
        source = RUNNER.read_text(encoding="utf-8")
        self.assertIn('mkdir -m700 "${install_lock}"', source)
        self.assertIn('mv -f "${confirm_file}" "${consumed_confirm_file}"', source)
        self.assertLess(source.index("destructive_started=true"),
                        source.index('archinstall --silent --config'))
        self.assertLess(source.index('progress "complete" 100'),
                        len(source))
        self.assertIn('[ -L "${target_root}/etc" ]', source)

    def test_preflight_does_not_retain_archinstall_credentials_as_reference(self):
        source = PREFLIGHT.read_text(encoding="utf-8")
        self.assertIn('rm -f -- "${reference_dir}/user_credentials.json"', source)
        self.assertIn('local credential_file="/var/log/archinstall/user_credentials.json"', source)
        self.assertIn('rm -f -- "${credential_file}"', source)
        self.assertNotIn(
            "for name in user_configuration.json user_credentials.json user_disk_layouts.json",
            source,
        )

    def test_arch_package_preflight_does_not_depend_on_curl(self):
        source = ARCH_PACKAGE_PREFLIGHT.read_text(encoding="utf-8")
        self.assertNotIn("curl ", source)
        self.assertIn("pacman --sync --refresh", source)

    def test_runner_recovers_confirmed_target_swap_before_unmounting(self):
        source = RUNNER.read_text(encoding="utf-8")
        self.assertIn('open("/proc/swaps"', source)
        self.assertIn('print("SWAP\\t" + source)', source)
        self.assertIn('swapoff -- "${target}"', source)
        self.assertLess(source.index('SWAP)'), source.index('MOUNT)'))

    def test_preflight_resolves_required_arch_packages_with_a_blank_sync_db(self):
        package_preflight = ARCH_PACKAGE_PREFLIGHT.read_text(encoding="utf-8")
        preflight = PREFLIGHT.read_text(encoding="utf-8")
        runner = RUNNER.read_text(encoding="utf-8")
        self.assertIn('pacman --sync --refresh', package_preflight)
        self.assertIn('--dbpath "${pacman_db}"', package_preflight)
        self.assertIn('pacman --sync --print', package_preflight)
        self.assertIn('packages.append("plasma-meta")', package_preflight)
        self.assertIn('"btrfs-progs"', package_preflight)
        self.assertIn('"e2fsprogs"', package_preflight)
        self.assertIn("preflight-arch-packages.sh", preflight)
        self.assertIn("preflight-arch-packages.sh", runner)
        self.assertLess(runner.index("preflighting_arch_packages"), runner.index("preflighting_meo_repository"))
        self.assertLess(runner.index("preflighting_meo_repository"), runner.index("if ! prepare_selected_mounts"))

    def test_preflight_refuses_a_symlinked_status_file_without_following_it(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / "state"
            state.mkdir(mode=0o700)
            outside = Path(directory) / "must-not-change"
            outside.write_text("sentinel\n", encoding="utf-8")
            (state / "preflight_status.json").symlink_to(outside)
            result = subprocess.run(
                ["bash", PREFLIGHT], text=True, capture_output=True,
                env=dict(os.environ, MEOARCH_INSTALLER_STATE_DIR=str(state)),
            )
            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertEqual(outside.read_text(encoding="utf-8"), "sentinel\n")

    def test_runner_rejects_symlinked_or_root_target_before_repository_or_disk_work(self):
        for unsafe_name in ("root", "symlink"):
            with self.subTest(unsafe_name=unsafe_name), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                state = root / "state"
                state.mkdir(mode=0o700)
                self._ready_state(state)
                installer_root = root / "installer"
                backend = installer_root / "backend"
                backend.mkdir(parents=True)
                generator = backend / "generate-config.py"
                generator.write_text("raise SystemExit(0)\n", encoding="utf-8")
                generator.chmod(0o755)
                repo_preflight = backend / "preflight-meo-repository.sh"
                repo_preflight.write_text("#!/bin/sh\ntouch \"$REPO_PREFLIGHT_CALLED\"\nexit 99\n", encoding="utf-8")
                repo_preflight.chmod(0o755)
                binaries = root / "bin"
                binaries.mkdir()
                archinstall = binaries / "archinstall"
                archinstall.write_text("#!/bin/sh\ntouch \"$ARCHINSTALL_CALLED\"\nexit 99\n", encoding="utf-8")
                archinstall.chmod(0o755)
                if unsafe_name == "root":
                    unsafe_target = "/"
                else:
                    mounted = root / "mounted-target"
                    mounted.mkdir()
                    unsafe_target = root / "target-link"
                    unsafe_target.symlink_to(mounted, target_is_directory=True)
                result = subprocess.run(
                    ["bash", RUNNER], text=True, capture_output=True,
                    env=dict(os.environ, PATH=f"{binaries}:{os.environ['PATH']}",
                             MEOARCH_INSTALLER_STATE_DIR=str(state),
                             MEOARCH_INSTALLER_ROOT=str(installer_root),
                             MEOARCH_TARGET_ROOT=str(unsafe_target),
                             ARCHINSTALL_CALLED=str(root / "archinstall-called"),
                             REPO_PREFLIGHT_CALLED=str(root / "repo-preflight-called")),
                )
                self.assertEqual(result.returncode, 7, result.stdout + result.stderr)
                self.assertFalse((root / "archinstall-called").exists())
                self.assertFalse((root / "repo-preflight-called").exists())


if __name__ == "__main__":
    unittest.main()
