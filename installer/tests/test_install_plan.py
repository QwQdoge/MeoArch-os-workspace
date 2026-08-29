import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / "backend"))
from install_plan import (PlanError, application_catalog_from, build_install_plan,
                          catalog_from, pacman_channel_fragment)


class InstallPlanTests(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog_from(ROOT / "data/package-catalog.json")
        self.application_catalog = application_catalog_from(
            ROOT / "data/application-catalog.json", self.catalog["generation"]
        )

    def test_catalog_is_bound_to_release_generation_and_repository_names(self):
        self.assertEqual(self.catalog["generation"], "2026.08")
        self.assertEqual(self.catalog["repositoryNames"], {"stable": "meo", "beta": "meo-beta"})

    def test_recommended_stable_has_complete_package_set(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "recommended", "channel": "stable"}, self.catalog)
        self.assertEqual(plan.repository.repositories, ("meo",))
        self.assertIn("meo-settings", plan.package.packages)
        self.assertIn("meo-account", plan.package.packages)
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

    def test_target_repository_configuration_validates_resolved_channel_order(self):
        script = (ROOT / "backend/configure-meo-repository.sh").read_text(encoding="utf-8")
        self.assertIn('actual != expected', script)
        self.assertIn('pacman-conf --repo-list', script)

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

    def test_recommended_profile_adds_system_apps_but_not_third_party(self):
        plan = build_install_plan(
            {"schemaVersion": 2, "profile": "recommended"}, self.catalog,
            application_catalog=self.application_catalog,
        )
        self.assertIn("ark", plan.applications.native_packages)
        self.assertIn("spectacle", plan.applications.native_packages)
        self.assertNotIn("gimp", plan.applications.native_packages)
        self.assertNotIn("firefox", plan.applications.native_packages)

    def test_selected_recommended_and_third_party_apps_are_catalog_resolved(self):
        plan = build_install_plan(
            {"schemaVersion": 2, "profile": "minimal",
             "applications": ["org.mozilla.firefox", "org.gimp.GIMP"]},
            self.catalog, application_catalog=self.application_catalog,
        )
        self.assertEqual(plan.applications.native_packages, ("firefox", "gimp"))
        self.assertEqual(plan.applications.source, "arch-official")

    def test_unknown_application_is_rejected(self):
        with self.assertRaises(PlanError):
            build_install_plan(
                {"schemaVersion": 2, "applications": ["invalid.app"]}, self.catalog,
                application_catalog=self.application_catalog,
            )
