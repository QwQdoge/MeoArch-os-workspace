import importlib.util
import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[2]
BACKEND = ROOT / "installer/backend"


def load_generate_config():
    spec = importlib.util.spec_from_file_location(
        "generate_config_responsiveness", BACKEND / "generate-config.py"
    )
    module = importlib.util.module_from_spec(spec)
    import sys
    sys.path.insert(0, str(BACKEND))
    try:
        spec.loader.exec_module(module)
    finally:
        sys.path.pop(0)
    return module


class ResponsivenessContractTests(unittest.TestCase):
    def test_installed_desktop_has_bounded_default_stack(self):
        module = load_generate_config()
        packages = module.build_package_list({"packages": []})
        for package in (
            "system76-scheduler", "zram-generator", "dbus-broker-units",
            "power-profiles-daemon", "gamemode",
        ):
            self.assertIn(package, packages)
        self.assertNotIn("ananicy-cpp", packages)
        self.assertNotIn("preload-ng", packages)
        self.assertNotIn("prelockd", packages)

    def test_target_enables_only_request_driven_services(self):
        customizer = (BACKEND / "apply-target-customizations.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("com.system76.Scheduler.service power-profiles-daemon.service", customizer)
        self.assertIn("disable ananicy-cpp.service", customizer)
        self.assertNotIn("enable gamemoded.service", customizer)


if __name__ == "__main__":
    unittest.main()
