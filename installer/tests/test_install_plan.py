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
        self.assertIn("meo-icon-studio", plan.package.packages)
        self.assertIn("meo-account", plan.package.packages)
        self.assertIn("omnistore-bin", plan.package.packages)
        self.assertIn("meo-release", plan.package.packages)

    def test_minimal_has_no_optional_apps(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "minimal", "channel": "stable"}, self.catalog)
        self.assertIn("meo-desktop", plan.package.packages)
        self.assertNotIn("meo-settings", plan.package.packages)
        self.assertNotIn("meo-icon-studio", plan.package.packages)
        self.assertNotIn("omnistore-bin", plan.package.packages)

    def test_beta_orders_overlay_before_stable(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "recommended", "channel": "beta"}, self.catalog)
        self.assertEqual(plan.repository.repositories, ("meo-beta", "meo"))
        fragment = pacman_channel_fragment(plan)
        self.assertLess(fragment.index("[meo-beta]"), fragment.index("[meo]"))

    def test_live_profile_resolves_omnistore_only_from_signed_meo_repositories(self):
        profile = (ROOT.parent / "meoarch-os/pacman.conf").read_text(encoding="utf-8")
        packages = (ROOT.parent / "meoarch-os/packages.x86_64").read_text(encoding="utf-8")
        active_profile = "\n".join(
            line for line in profile.splitlines() if not line.lstrip().startswith("#")
        )
        self.assertIn("\nomnistore-bin\n", f"\n{packages}\n")
        self.assertLess(active_profile.index("[meo-beta]"), active_profile.index("[meo]"))
        self.assertEqual(active_profile.count("SigLevel = Required TrustedOnly"), 2)
        self.assertEqual(active_profile.count("Server = https://packages.meoarch.org/$repo/os/$arch"), 2)
        self.assertNotIn("TrustAll", active_profile)

    def test_iso_build_stages_only_public_arch_and_meo_keyring_inputs(self):
        script = (ROOT.parent / "scripts/stage-build-keyring.sh").read_text(encoding="utf-8")
        build = (ROOT.parent / "scripts/build-iso.sh").read_text(encoding="utf-8")
        profile = (ROOT.parent / "meoarch-os/profiledef.sh").read_text(encoding="utf-8")
        self.assertIn("archlinux.gpg", script)
        self.assertIn("meo.gpg", script)
        self.assertIn("list-secret-keys", script)
        self.assertIn("Refusing a build keyring that contains a private key", script)
        self.assertIn("pubring.*~", script)
        self.assertIn("mktemp -d /tmp/meo-archiso-keyring.", script)
        self.assertIn("stage-build-keyring.sh", build)
        self.assertLess(build.index("stage-build-keyring.sh"), build.index("verify-staging-provenance.sh"))
        self.assertIn('cd "${repo_root}"', build)
        self.assertIn('["/etc/pacman.d/gnupg/"]="0:0:700"', profile)

    def test_target_repository_configuration_validates_resolved_channel_order(self):
        script = (ROOT / "backend/configure-meo-repository.sh").read_text(encoding="utf-8")
        self.assertIn('actual != expected', script)
        self.assertIn('pacman-conf --repo-list', script)

    def test_settings_target_checks_the_packaged_icon_studio_not_a_developer_copy(self):
        runner = (ROOT / "backend/run-archinstall.sh").read_text(encoding="utf-8")
        self.assertIn("meo-app-icon-studio", runner)
        self.assertIn("pacman -Qo", runner)
        self.assertIn("pacman -Qkk meo-icon-studio", runner)
        self.assertIn("meo-settings", runner)

    def test_repository_preflight_covers_bootstrap_channel_and_profile_packages(self):
        script = (ROOT / "backend/preflight-meo-repository.sh").read_text(encoding="utf-8")
        self.assertIn('bootstrap_packages = repository.get("bootstrapPackages")', script)
        self.assertIn('channel_package = repository.get("channelPackage")', script)
        self.assertIn('transaction_packages = list(dict.fromkeys(', script)

    def test_custom_forces_desktop_dependencies(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "custom", "channel": "stable", "components": ["meo-desktop", "omnistore-bin"]}, self.catalog)
        self.assertTrue({"meo-desktop", "meoui-qml", "meo-icons", "omnistore-bin"}.issubset(plan.package.packages))

    def test_custom_without_desktop_is_rejected(self):
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2, "profile": "custom", "components": ["omnistore-bin"]}, self.catalog)

    def test_custom_settings_closes_the_package_owned_icon_studio(self):
        plan = build_install_plan(
            {"schemaVersion": 2, "profile": "custom", "channel": "stable",
             "components": ["meo-desktop", "meo-settings"]},
            self.catalog,
        )
        self.assertIn("meo-icon-studio", plan.package.packages)
        self.assertIn("meo-icons", plan.package.packages)

    def test_custom_components_must_be_a_real_package_list(self):
        for invalid in (None, "meo-desktop", ["meo-desktop", None], ["meo-desktop", "bad package"]):
            with self.subTest(invalid=invalid):
                with self.assertRaisesRegex(PlanError, "custom components must be a list"):
                    build_install_plan(
                        {"schemaVersion": 2, "profile": "custom", "components": invalid},
                        self.catalog,
                    )

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

    def test_installer_application_catalog_has_reviewed_chinese_user_copy(self):
        raw_catalog = json.loads((ROOT / "data/application-catalog.json").read_text(encoding="utf-8"))
        installable = [
            app for app in raw_catalog["applications"]
            if app["installer"]["source"] == "arch-official"
        ]
        self.assertTrue(installable)
        for app in installable:
            localized = app.get("translations", {}).get("zh_CN", {})
            self.assertTrue(localized.get("summary"), app["id"])
            self.assertTrue(localized.get("category"), app["id"])

    def test_unknown_application_is_rejected(self):
        with self.assertRaises(PlanError):
            build_install_plan(
                {"schemaVersion": 2, "applications": ["invalid.app"]}, self.catalog,
                application_catalog=self.application_catalog,
            )
