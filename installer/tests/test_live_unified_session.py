"""The Live desktop is the installed Meo session on the same signed packages."""
import configparser
import importlib.machinery
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
PACKAGES = ROOT / "meoarch-os/packages.x86_64"
PROFILE = ROOT / "meoarch-os/airootfs"
SYNC = ROOT / "scripts/sync-installer-to-airootfs.sh"
PIN_CHECK = ROOT / "scripts/check-meoui-pin.py"


def _load(path, name):
    loader = importlib.machinery.SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def _package_names():
    return {line.strip() for line in PACKAGES.read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")}


class LiveUsesTheMeoSessionTests(unittest.TestCase):
    def test_live_entry_wraps_the_meo_session(self):
        entry = configparser.ConfigParser(interpolation=None)
        entry.optionxform = str
        entry.read_string((ROOT / "installer/data/wayland-sessions/meoarch-live.desktop").read_text())
        desktop = entry["Desktop Entry"]
        self.assertEqual(desktop["Exec"], "/usr/lib/meoarch/live-session")
        self.assertEqual(desktop["TryExec"], "/usr/bin/startmeo-wayland")
        # Meo Login Manager passes DesktopNames to logind verbatim (no ';' -> ':'
        # conversion), and live-installer-authorize splits the logind Desktop
        # property on ':'. "KDE;Meo" therefore reads as one unknown name and the
        # Live installer launch is rejected; keep a single name.
        self.assertEqual(desktop["DesktopNames"], "KDE")
        authorize = (ROOT / "installer/bin/meoarch-live-session").parent / "meoarch-live-installer-authorize"
        self.assertIn("facts.get('Desktop', '').split(':')", authorize.read_text())

    def test_normal_path_runs_startmeo_and_safe_path_stays_stock_plasma(self):
        session = _load(ROOT / "installer/bin/meoarch-live-session", "live_session_unified")
        self.assertEqual(session.MEO_COMMAND, "/usr/bin/startmeo-wayland")
        self.assertEqual(session.SAFE_COMMAND, "/usr/bin/startplasma-wayland")
        source = (ROOT / "installer/bin/meoarch-live-session").read_text()
        # startmeo-wayland owns the Meo environment; the wrapper must not set a
        # second, divergent copy for the normal path.
        self.assertNotIn("PLASMA_DEFAULT_SHELL='org.meo.shell'", source)
        self.assertIn("if safe and name in launch_environment", source)

    def test_live_lock_override_lives_in_the_meo_session_config_home(self):
        # startmeo-wayland moves XDG_CONFIG_HOME to ~/.config/meo-desktop and only
        # seeds files that are missing, so the Live override must be there.
        override = PROFILE / "home/live/.config/meo-desktop/kscreenlockerrc"
        self.assertIn("Autolock=false", override.read_text())
        self.assertFalse((PROFILE / "home/live/.config/kscreenlockerrc").exists())
        profiledef = (ROOT / "meoarch-os/profiledef.sh").read_text()
        self.assertIn('["/home/live/.config/meo-desktop/kscreenlockerrc"]="1000:1000:600"', profiledef)

    def test_live_uses_the_meo_login_manager_and_package_desktop(self):
        packages = _package_names()
        self.assertTrue({"meo-plasma-login-manager", "meo-desktop", "meoui-qml"} <= packages)
        # The Meo fork provides and replaces the upstream package; listing both
        # would make pacstrap fail on the conflict.
        self.assertNotIn("plasma-login-manager", packages)

    def test_tracked_profile_holds_no_package_owned_desktop_snapshot(self):
        # The overlay is extracted after pacstrap, so any committed copy of a
        # package-owned file silently replaces the signed package in the Live
        # image (an old layout without the Shelf shipped this way).
        tracked = subprocess.run(["git", "-C", str(ROOT), "ls-files", "meoarch-os/airootfs"],
                                 capture_output=True, text=True, check=True).stdout.splitlines()
        owned = ("usr/share/plasma/", "usr/share/color-schemes/", "usr/share/fcitx5/",
                 "usr/share/meo-desktop/", "usr/share/pixmaps/", "usr/share/wallpapers/",
                 "usr/share/dbus-1/", "etc/fonts/", "etc/xdg/kdeglobals", "etc/xdg/kwinrc",
                 "usr/share/icons/Meo", "usr/share/icons/hicolor/scalable/apps/meoarch-logo.svg")
        offenders = [path for path in tracked
                     if any(path.removeprefix("meoarch-os/airootfs/").startswith(prefix) for prefix in owned)]
        self.assertEqual(offenders, [])

    def test_profile_carries_no_global_kde_or_meo_defaults(self):
        for relative in ("etc/xdg/kdeglobals", "etc/xdg/kwinrc", "etc/xdg/plasmarc",
                         "etc/xdg/plasma-welcomerc", "etc/xdg/kglobalshortcutsrc",
                         "etc/xdg/meo-shellrc", "etc/xdg/fcitx5/conf/classicui.conf",
                         "etc/environment.d/90-meo-applications.conf"):
            with self.subTest(relative=relative):
                self.assertFalse((PROFILE / relative).exists())

    def test_sync_stages_no_package_owned_desktop_files(self):
        # Statements that write into the Live root (`${airootfs}`), ignoring
        # comments and the runtime_root inputs of the installer/repair build.
        source = SYNC.read_text(encoding="utf-8")
        joined = source.replace("\\\n", " ")
        writes = [line for line in joined.splitlines()
                  if "${airootfs}" in line and not line.lstrip().startswith("#")]
        staged = "\n".join(writes)
        for fragment in ("qt6/qml/MeoUI", "qt6/qml/MeoKDE", "qt6/qml/Meo/System", "libmeoui.so",
                         "meo-session-actiond", "meo-weather-refresh\"", "kdecoration3", "meostyle.so",
                         "plasma/look-and-feel", "plasma/plasmoids", "plasma/shells",
                         "plasma/desktoptheme", "color-schemes", "wallpapers/MeoArch",
                         "meoarch-logo.svg", "etc/xdg/kdeglobals", "etc/os-release",
                         "meo-input-method", "apply-meo-desktop", "environment.d",
                         "fcitx5/themes", "usr/share/fonts/meo"):
            with self.subTest(fragment=fragment):
                self.assertNotIn(fragment, staged)
        # Only the Cage repair session's polkit agent is still built from source.
        self.assertIn("--target meo-polkit-agent", source)
        self.assertIn("check-meoui-pin.py", source)


class InstallerIsPackageOnlyTests(unittest.TestCase):
    """The installed desktop comes from pacman; nothing is copied from the Live medium."""

    def test_target_customization_has_no_non_package_branch(self):
        source = (ROOT / "installer/backend/apply-target-customizations.sh").read_text()
        runner = (ROOT / "installer/backend/run-archinstall.sh").read_text()
        for text in (source, runner):
            self.assertNotIn("/opt/meo-desktop", text)
            self.assertNotIn("MEOARCH_PACKAGE_MANAGED", text)
        self.assertNotIn("desktop_source", source)
        self.assertIn('"${target_root}" "${generated_dir}"', runner)
        # Package-owned files are verified, never overwritten from the Live runtime.
        code = "\n".join(line for line in source.splitlines() if not line.lstrip().startswith("#"))
        for package_owned in ("meo-session-actiond", "libmeoui", "qt6/qml/Meo", "look-and-feel",
                              "plasma/plasmoids", "etc/xdg/kdeglobals", "90-meo-applications"):
            with self.subTest(package_owned=package_owned):
                self.assertNotIn(package_owned, code)

    def test_target_verifier_is_the_only_post_install_check(self):
        script = (ROOT / "scripts/verify-target-install.sh").read_text()
        self.assertIn("verify-target.py", script)
        self.assertNotIn("opt/meo-desktop", script)
        self.assertNotIn("MEOARCH_PACKAGE_MANAGED", script)

    def test_live_image_stages_no_desktop_payload(self):
        self.assertNotIn('install -d \\\n  "${desktop_dst}', SYNC.read_text())
        self.assertIn('rm -rf "${legacy_desktop_payload_dst}"', SYNC.read_text())


class ArchinstallInstallsNoDesktopTests(unittest.TestCase):
    PREFLIGHT = ROOT / "installer/backend/preflight-arch-packages.sh"

    def _preflight_packages(self, profile_config):
        source = self.PREFLIGHT.read_text()
        start = source.index("<<'PY'\n", source.index("mapfile -t arch_packages")) + len("<<'PY'\n")
        code = source[start:source.index("\nPY\n", start)]
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "config.json"
            config.write_text(json.dumps({"kernels": ["linux"], "packages": ["dolphin"],
                                          "profile_config": profile_config}))
            return subprocess.run(["python3", "-I", "-c", code, str(config)],
                                  capture_output=True, text=True)

    def test_generated_config_selects_the_minimal_profile(self):
        sys.path.insert(0, str(ROOT / "installer/backend"))
        self.addCleanup(sys.path.remove, str(ROOT / "installer/backend"))
        generate = _load(ROOT / "installer/backend/generate-config.py", "generate_config_unified")
        profile = generate.build_user_configuration({}, {"vendors": [], "packages": []})["profile_config"]
        self.assertEqual(profile, {"gfx_driver": None, "greeter": None,
                                   "profile": {"main": "Minimal", "details": []}})
        self.assertNotIn("plasma_flavor", (ROOT / "installer/backend/generate-config.py").read_text())

    def test_preflight_still_covers_the_plasma_runtime_before_any_disk_change(self):
        result = self._preflight_packages({"profile": {"main": "Minimal", "details": []}})
        self.assertEqual(result.returncode, 0, result.stderr)
        packages = result.stdout.split()
        self.assertTrue({"plasma-desktop", "plasma-workspace", "dolphin", "linux"} <= set(packages))

    def test_preflight_rejects_a_desktop_profile(self):
        for profile in ({"main": "Desktop", "details": ["KDE Plasma"]},
                        {"main": "Minimal", "details": ["KDE Plasma"]}):
            with self.subTest(profile=profile):
                self.assertNotEqual(self._preflight_packages({"profile": profile}).returncode, 0)


class MeoUiPinTests(unittest.TestCase):
    def setUp(self):
        self.pin = _load(PIN_CHECK, "check_meoui_pin")

    def _manifest(self, directory, commit):
        path = Path(directory) / "manifest.json"
        path.write_text(json.dumps({"components": {"meoui-qml": {"commit": commit}}}))
        return path

    def test_reads_the_pinned_commit(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(self.pin.pinned_commit(self._manifest(directory, "a" * 40)), "a" * 40)

    def test_rejects_a_manifest_without_a_valid_pin(self):
        with tempfile.TemporaryDirectory() as directory:
            for commit in ("abc", None):
                with self.subTest(commit=commit):
                    with self.assertRaises(SystemExit):
                        self.pin.pinned_commit(self._manifest(directory, commit))

    def test_mismatch_fails_and_match_passes(self):
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory) / "meoui"
            repo.mkdir()
            git = ["git", "-C", str(repo), "-c", "user.name=t", "-c", "user.email=t@example.test"]
            subprocess.run([*git, "init", "-q"], check=True)
            subprocess.run([*git, "commit", "-q", "--allow-empty", "-m", "x"], check=True)
            head = subprocess.run([*git, "rev-parse", "HEAD"], capture_output=True, text=True, check=True).stdout.strip()
            good = self._manifest(directory, head)
            self.assertEqual(subprocess.run(["python3", str(PIN_CHECK), str(repo), str(good)],
                                            capture_output=True).returncode, 0)
            bad = self._manifest(directory, "b" * 40)
            self.assertEqual(subprocess.run(["python3", str(PIN_CHECK), str(repo), str(bad)],
                                            capture_output=True).returncode, 1)


if __name__ == "__main__":
    unittest.main()
