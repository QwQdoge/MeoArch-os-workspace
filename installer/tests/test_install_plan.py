import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / "backend"))
from install_plan import PlanError, build_install_plan, catalog_from, pacman_channel_fragment


class InstallPlanTests(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog_from(ROOT / "data/package-catalog.json")

    def test_recommended_stable_has_complete_package_set(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "recommended", "channel": "stable"}, self.catalog)
        self.assertEqual(plan.repository.repositories, ("meo",))
        self.assertIn("meo-settings", plan.package.packages)
        self.assertIn("omnistore-bin", plan.package.packages)
        self.assertIn("meo-release", plan.package.packages)

    def test_minimal_has_no_optional_apps(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "minimal", "channel": "stable"}, self.catalog)
        self.assertIn("meo-desktop", plan.package.packages)
        self.assertNotIn("meo-settings", plan.package.packages)
        self.assertNotIn("omnistore-bin", plan.package.packages)

    def test_beta_orders_overlay_before_stable(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "recommended", "channel": "beta"}, self.catalog)
        self.assertEqual(plan.repository.repositories, ("meo-beta", "meo"))
        fragment = pacman_channel_fragment(plan)
        self.assertLess(fragment.index("[meo-beta]"), fragment.index("[meo]"))

    def test_custom_forces_desktop_dependencies(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "custom", "channel": "stable", "components": ["meo-desktop", "omnistore-bin"]}, self.catalog)
        self.assertTrue({"meo-desktop", "meoui-qml", "meo-icons", "omnistore-bin"}.issubset(plan.package.packages))

    def test_custom_without_desktop_is_rejected(self):
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2, "profile": "custom", "components": ["omnistore-bin"]}, self.catalog)

    def test_unknown_architecture_and_mirror_fail_before_install(self):
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2}, self.catalog, "aarch64")
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2, "mirror": "untrusted"}, self.catalog)

