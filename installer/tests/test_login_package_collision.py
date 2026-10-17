"""Exercise the collision guard against a disposable real pacman database."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


RUNNER = Path(__file__).parents[1] / "backend/run-archinstall.sh"


@unittest.skipUnless(shutil.which("pacman"), "requires pacman")
class LoginPackageCollisionTests(unittest.TestCase):
    def check_guard(self, upstream=False, query_failure=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            local = root / "db/local"
            local.mkdir(parents=True)
            version = Path("/var/lib/pacman/local/ALPM_DB_VERSION")
            if not version.is_file():
                self.skipTest("local pacman database format unavailable")
            shutil.copy(version, local / "ALPM_DB_VERSION")
            packages = ["meo-plasma-login-manager"]
            if upstream:
                packages.append("plasma-login-manager")
            for name in packages:
                package = local / (name + "-6.7.5-4")
                package.mkdir()
                desc = f"%NAME%\n{name}\n\n%VERSION%\n6.7.5-4\n\n%ARCH%\nx86_64\n\n"
                if name.startswith("meo-"):
                    desc += "%PROVIDES%\nplasma-login-manager=6.7.5\n\n"
                (package / "desc").write_text(desc)
                (package / "files").write_text("%FILES%\n\n")
            config = root / "pacman.conf"
            config.write_text("[options]\nArchitecture = auto\n")
            # Demonstrate the original false positive without touching host DBs.
            named = subprocess.run(
                ["pacman", "--config", str(config), "--dbpath", str(root / "db"),
                 "-Q", "plasma-login-manager"], capture_output=True, text=True,
            )
            self.assertEqual(named.returncode, 0, named.stderr)
            if not upstream:
                self.assertIn("meo-plasma-login-manager", named.stdout)
            source = RUNNER.read_text()
            start = source.index('  installed_package_names="$(arch-chroot')
            end = source.index('  login_check=', start)
            guard = source[start:end]
            # Run only this read-only guard, never the installation engine.
            script = '''set -euo pipefail
arch-chroot() {
    [ "$QUERY_FAILURE" = 0 ] || return 1
    shift
    [ "$1" = pacman ] || return 2
    shift
    command pacman --config "$FIXTURE_CONFIG" --dbpath "$FIXTURE_DB" "$@"
}
target_root=/fixture
log_file=/dev/null
''' + guard
            return subprocess.run(
                ["bash", "-c", script], capture_output=True, text=True,
                env=dict(os.environ, FIXTURE_CONFIG=str(config), FIXTURE_DB=str(root / "db"),
                         QUERY_FAILURE="1" if query_failure else "0"),
            )

    def test_virtual_provider_is_not_an_upstream_package(self):
        result = self.check_guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_actual_upstream_package_is_rejected(self):
        result = self.check_guard(upstream=True)
        self.assertEqual(result.returncode, 12, result.stderr)
        self.assertIn("installed alongside", result.stderr)

    def test_failed_inventory_query_fails_closed(self):
        result = self.check_guard(query_failure=True)
        self.assertEqual(result.returncode, 12, result.stderr)
        self.assertIn("Could not enumerate installed packages", result.stderr)
