import importlib.util
import json
from importlib.machinery import SourceFileLoader
import tempfile
import unittest
from pathlib import Path
from unittest import mock


WRAPPER = Path(__file__).parents[2] / "meoarch-os" / "airootfs" / "usr" / "local" / "bin" / "archinstall"
LOADER = SourceFileLoader("meoarch_archinstall_wrapper", str(WRAPPER))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
if SPEC is None:
    raise RuntimeError(f"Could not create import spec for Archinstall wrapper: {WRAPPER}")
MODULE = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(MODULE)


class ArchinstallWrapperTests(unittest.TestCase):
    def test_real_install_defers_only_keyboard_and_restores_original_locale(self):
        with tempfile.TemporaryDirectory() as directory:
            generated = Path(directory) / "generated"
            generated.mkdir()
            config = generated / "user_configuration.json"
            original_locale = {"kb_layout": "de", "sys_lang": "de_DE.UTF-8", "sys_enc": "UTF-8"}
            config.write_text(json.dumps({"locale_config": original_locale, "hostname": "meotest"}))

            def run(command, **kwargs):
                if command[0] == "/usr/bin/localectl":
                    return mock.Mock(stdout="de\nus\n", returncode=0)
                runtime = Path(command[command.index("--config") + 1])
                self.assertEqual(kwargs["umask"], 0o022)
                payload = json.loads(runtime.read_text())
                self.assertEqual(payload["locale_config"], dict(original_locale, kb_layout=""))
                self.assertEqual(payload["hostname"], "meotest")
                return mock.Mock(returncode=0)

            with mock.patch.object(MODULE.sys, "argv", ["archinstall", "--silent", "--config", str(config)]), \
                 mock.patch.object(MODULE.subprocess, "run", side_effect=run), \
                 mock.patch.object(MODULE, "apply_locale") as apply:
                self.assertEqual(MODULE.main(), 0)
                self.assertEqual(apply.call_args.args[1], original_locale)
            self.assertEqual(json.loads(config.read_text())["locale_config"], original_locale)
            self.assertEqual(list(generated.glob(".meoarch-archinstall-*")), [])

    def test_config_argument_supports_split_and_equals_forms(self):
        self.assertEqual(MODULE.config_argument(["--silent", "--config", "/tmp/a.json"]), (2, "/tmp/a.json"))
        self.assertEqual(MODULE.config_argument(["--silent", "--config=/tmp/b.json"]), (1, "/tmp/b.json"))

    def test_dry_run_passes_original_configuration_through(self):
        argv = ["--silent", "--dry-run", "--config", "/tmp/generated/user_configuration.json", "--creds", "/tmp/creds.json"]
        with mock.patch.object(MODULE.sys, "argv", ["archinstall", *argv]), \
             mock.patch.object(MODULE, "passthrough", return_value=23) as passthrough:
            self.assertEqual(MODULE.main(), 23)
            passthrough.assert_called_once_with(argv)

    def test_enable_locale_uncomments_only_selected_locale(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "locale.gen"
            path.write_text("#en_US.UTF-8 UTF-8\n#de_DE.UTF-8 UTF-8\n", encoding="utf-8")
            MODULE.enable_locale(path, "en_US.UTF-8", "UTF-8")
            self.assertEqual(path.read_text(encoding="utf-8"), "en_US.UTF-8 UTF-8\n#de_DE.UTF-8 UTF-8\n")

    def test_apply_locale_writes_persistent_files_without_localectl(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "etc").mkdir()
            (root / "usr").mkdir()
            (root / "etc/locale.gen").write_text("#en_US.UTF-8 UTF-8\n", encoding="utf-8")
            with mock.patch.object(MODULE.subprocess, "run") as run:
                run.return_value.returncode = 0
                MODULE.apply_locale(root, {"kb_layout": "us", "sys_lang": "en_US.UTF-8", "sys_enc": "UTF-8"})
            self.assertEqual((root / "etc/vconsole.conf").read_text(encoding="utf-8"), "KEYMAP=us\n")
            self.assertEqual((root / "etc/locale.conf").read_text(encoding="utf-8"), "LANG=en_US.UTF-8\n")
            self.assertEqual((root / "etc/locale.gen").read_text(encoding="utf-8"), "en_US.UTF-8 UTF-8\n")
            run.assert_called_once_with(["/usr/bin/arch-chroot", str(root.resolve()), "/usr/bin/locale-gen"], check=False)


if __name__ == "__main__":
    unittest.main()
