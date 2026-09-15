import re
import unittest
from pathlib import Path


QML_ROOT = Path(__file__).parents[1] / "qml"
RAW_RECTANGLE = re.compile(r"\bRectangle\s*\{")
RAW_COLOR = re.compile(
    r"#[0-9A-Fa-f]{3,8}\b|color\s*:\s*[\"'](?:white|black|transparent)[\"']"
)


class InstallerDesignSystemTests(unittest.TestCase):
    def test_visual_qml_does_not_bypass_meoui_surfaces_or_tokens(self):
        violations = []
        for qml_file in sorted(QML_ROOT.rglob("*.qml")):
            source = qml_file.read_text(encoding="utf-8")
            if RAW_RECTANGLE.search(source) or RAW_COLOR.search(source):
                violations.append(str(qml_file.relative_to(QML_ROOT)))
        self.assertEqual(
            violations,
            [],
            "Use MeoUI surfaces and named MeoTheme roles instead of raw rectangles or colour literals.",
        )

    def test_page_frame_uses_the_shared_surface_and_divider(self):
        source = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        self.assertIn("MeoMotionSurface", source)
        self.assertIn("MeoDivider", source)

    def test_installer_uses_meoui_104_page_loading_contract(self):
        cmake = (QML_ROOT.parent / "CMakeLists.txt").read_text(encoding="utf-8")
        main = (QML_ROOT / "Main.qml").read_text(encoding="utf-8")
        self.assertIn('VERSION_LESS "1.0.4"', cmake)
        self.assertIn("sourceProperties:", main)
        self.assertIn('pageKey: String(root.currentPage) + "-" + String(root.startupAttempt)', main)
        self.assertIn("loadingAccessibleName:", main)
        self.assertNotIn("onPageLoaded:", main)

    def test_startup_is_localized_fail_closed_and_visually_minimal(self):
        host = (QML_ROOT.parent / "app/main.cpp").read_text(encoding="utf-8")
        main = (QML_ROOT / "Main.qml").read_text(encoding="utf-8")
        launcher = (QML_ROOT.parent / "bin/meoarch-installer").read_text(encoding="utf-8")
        welcome = (QML_ROOT / "pages/WelcomePage.qml").read_text(encoding="utf-8")
        self.assertLess(
            host.index("loadLanguage(controller.uiLanguage());"),
            host.index("engine.load(QUrl::fromLocalFile"),
        )
        self.assertIn("startupTimedOut", main)
        self.assertIn("startupAttempt++", main)
        self.assertIn('qsTr("Preparing installer")', main)
        self.assertIn('qsTr("Installer could not open")', main)
        self.assertNotIn("qml6", launcher)
        self.assertNotIn("qmlscene", launcher)
        self.assertIn("native MeoArch Installer host is missing", launcher)
        self.assertNotIn("Repeater", welcome)
        self.assertIn('qsTr("Review first. Nothing changes until you confirm.")', welcome)

    def test_power_dialog_uses_md_motion_and_hold_confirmation(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        self.assertIn("presentation: MeoMotionPopup.Dialog", frame)
        self.assertEqual(frame.count("MeoHoldToConfirm {"), 2)
        self.assertIn('confirmationText: qsTr("Hold to restart")', frame)
        self.assertIn('confirmationText: qsTr("Hold to shut down")', frame)
        self.assertIn("holdDuration: 1200", frame)
        self.assertIn("KeyNavigation.down: shutdownAction", frame)

    def test_async_disk_and_preflight_work_have_explicit_loading_states(self):
        header = (QML_ROOT.parent / "app/installercontroller.h").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        preview = (QML_ROOT / "PreviewController.qml").read_text(encoding="utf-8")
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn("Q_PROPERTY(bool diskDetecting", header)
        self.assertIn("if (m_diskDetecting)", controller)
        self.assertIn("QProcess::FailedToStart", controller)
        self.assertIn("property bool diskDetecting: false", preview)
        self.assertIn("!page.controller.diskDetecting", disk)
        self.assertIn("!controller.diskDetecting", disk)
        self.assertIn("MeoLoadingFeedback", disk)
        self.assertIn('accessibleName: qsTr("Scanning storage devices")', disk)
        self.assertIn("property bool primaryLoading: false", frame)
        self.assertIn("loading: frame.primaryLoading", frame)
        self.assertIn('primaryLoading: controller && controller.preflightState === "checking"', summary)

    def test_custom_profile_persists_required_desktop_and_review_shows_resolved_plan(self):
        software = (QML_ROOT / "pages/SoftwarePage.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn('value === "custom" ? ["meo-desktop"] : []', software)
        self.assertIn("controller.installPlan.repository", summary)
        self.assertIn("controller.installPlan.package", summary)
        self.assertIn("controller.installPlan.applications", summary)
        self.assertIn("Validated Meo package plan", summary)

    def test_software_page_exposes_system_recommended_and_opt_in_third_party_tiers(self):
        software = (QML_ROOT / "pages/SoftwarePage.qml").read_text(encoding="utf-8")
        self.assertIn('applicationsForTier("system")', software)
        self.assertIn('applicationsForTier("recommended")', software)
        self.assertIn('applicationsForTier("third-party")', software)
        self.assertIn("Always opt-in", software)
        self.assertIn("Arch official · package:", software)
        self.assertIn("Flatpak and AUR are not installer sources", software)

    def test_disk_page_keeps_partition_planning_inside_the_cage_client(self):
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        preview = (QML_ROOT / "PreviewController.qml").read_text(encoding="utf-8")
        self.assertIn("Use one existing partition", disk)
        self.assertIn("selectExistingPartition", disk)
        self.assertIn('"targetPartition"', disk)
        self.assertIn("EFI System Partition", disk)
        self.assertIn('"disk.sizeBytes": 549755813888', preview)
        self.assertIn("eligibleEfi:true", preview)
        self.assertNotIn("gparted", disk.casefold())

    def test_choice_cards_expose_selection_semantics_without_turning_status_cards_into_buttons(self):
        card = (QML_ROOT / "components/SelectionCard.qml").read_text(encoding="utf-8")
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn("property bool selectionIndicator: false", card)
        self.assertIn("Accessible.RadioButton", card)
        self.assertIn("selectionIndicator: true", disk)
        self.assertIn("Installation plan ready", summary)
        self.assertIn("final erase confirmation", summary)

    def test_installing_page_explains_verified_progress_and_maps_backend_stage_ids(self):
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parents[0] / "app/installercontroller.cpp").read_text(encoding="utf-8")
        self.assertIn('stage === "installing_base"', installing)
        self.assertIn("Progress updates at verified stages", installing)
        self.assertIn("same percentage", installing)
        self.assertIn("installationFailureDetails", installing)
        self.assertIn("setProcessChannelMode(QProcess::MergedChannels)", controller)

    def test_installer_only_shows_real_or_explicitly_unavailable_choices(self):
        user = (QML_ROOT / "pages/UserAccountPage.qml").read_text(encoding="utf-8")
        software = (QML_ROOT / "pages/SoftwarePage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parents[0] / "app/installercontroller.cpp").read_text(encoding="utf-8")
        self.assertIn("Password sign-in required", user)
        self.assertNotIn("Automatic login\")", user)
        self.assertIn("Included with every MeoArch installation", software)
        self.assertNotIn('enabled: false', software)
        self.assertIn('row({{"id", "zh_CN"}', controller)
        self.assertNotIn('row({{"id", "ja"}', controller)
        self.assertIn("uiLanguages.length > 1", (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8"))

    def test_language_page_wraps_the_packaged_plasma_offline_timezone_selector(self):
        page = (QML_ROOT / "pages/LanguageRegionPage.qml").read_text(encoding="utf-8")
        wrapper = (QML_ROOT / "components/MeoTimezoneSelector.qml").read_text(encoding="utf-8")
        kde_selector = (QML_ROOT / "components/KdeTimezoneSelector.qml").read_text(encoding="utf-8")
        packages = (QML_ROOT.parents[1] / "meoarch-os/packages.x86_64").read_text(encoding="utf-8")
        self.assertIn("MeoTimezoneSelector", page)
        self.assertIn('source: "KdeTimezoneSelector.qml"', wrapper)
        self.assertIn("org.kde.plasma.workspace.timezoneselector", kde_selector)
        self.assertIn("property alias selectedTimeZone", kde_selector)
        self.assertIn("plasma-workspace", packages)
        self.assertIn("qt6-location", packages)

    def test_language_page_is_country_first_with_real_adjustments_and_calendar_boundaries(self):
        page = (QML_ROOT / "pages/LanguageRegionPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        presets = (QML_ROOT.parent / "data/region-presets.json").read_text(encoding="utf-8")
        self.assertIn("Ready for you", page)
        self.assertIn("Use country recommendations again", page)
        self.assertIn("The installer never contacts this service", page)
        self.assertIn("CN", presets)
        self.assertIn("HK", presets)
        self.assertIn("KR", presets)
        self.assertIn("SG", presets)
        self.assertIn("manualSystemLocale", controller)
        self.assertIn("applyRegionPreset", controller)
        self.assertIn("manualTimezone", controller)
        self.assertIn("manualKeyboardLayout", controller)
        self.assertIn("setFormatLocale", controller)
        self.assertIn("Date and number formats", page)
        selector = (QML_ROOT / "components/SelectorDialog.qml").read_text(encoding="utf-8")
        self.assertIn("function isSelectable", selector)
        self.assertIn('state === "needs-online-setup"', selector)

    def test_installer_keeps_cloud_account_authentication_out_of_the_local_user_flow(self):
        user = (QML_ROOT / "pages/UserAccountPage.qml").read_text(encoding="utf-8").casefold()
        self.assertNotIn("meo account", user)
        self.assertNotIn("oauth", user)

    def test_network_handoff_is_explicit_and_never_serializes_profile_secrets(self):
        network = (QML_ROOT / "pages/NetworkPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        customizer = (QML_ROOT.parent / "backend/apply-target-customizations.sh").read_text(encoding="utf-8")
        self.assertIn("Remember this network after installation", network)
        self.assertIn("network-handoff.nmconnection", controller)
        self.assertIn("NetworkManager/system-connections", customizer)
        self.assertIn("isSupportedNetworkHandoffProfile", controller)
        self.assertIn('"wpa-psk"', controller)
        self.assertIn('"sae"', controller)
        self.assertIn('"owe"', controller)
        self.assertNotIn("sourcePath", (QML_ROOT.parent / "data/default_selections.json").read_text(encoding="utf-8"))

    def test_installer_has_real_debug_terminal_and_archwiki_fallback(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        packages = (QML_ROOT.parents[1] / "meoarch-os/packages.x86_64").read_text(encoding="utf-8")
        self.assertIn("openDebugTerminal", frame)
        self.assertIn("https://wiki.archlinux.org/title/Installation_guide", frame)
        self.assertIn("https://wiki.archlinux.org/title/Network_configuration", frame)
        self.assertIn("QProcess::startDetached", controller)
        self.assertIn('QStringLiteral("konsole")', controller)
        self.assertIn("\nkonsole\n", f"\n{packages}\n")
        self.assertTrue((QML_ROOT.parents[1] / "assets/wallpapers/installer_background.png").is_file())

    def test_minimum_window_uses_compact_install_and_finish_layouts(self):
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")
        finish = (QML_ROOT / "pages/FinishPage.qml").read_text(encoding="utf-8")
        self.assertIn("page.compactHeight ? page.dp(138)", installing)
        self.assertIn("page.compactHeight ? page.dp(72)", finish)
        self.assertIn("page.compactHeight ? page.dp(68)", finish)

    def test_user_visible_static_strings_are_translation_eligible(self):
        offenders = []
        literal = re.compile(r'^\s*(?:text|title|subtitle|label|placeholder):\s*"', re.MULTILINE)
        for qml_file in sorted(QML_ROOT.rglob("*.qml")):
            if literal.search(qml_file.read_text(encoding="utf-8")):
                offenders.append(str(qml_file.relative_to(QML_ROOT)))
        self.assertEqual(offenders, [], "Wrap user-visible QML strings with qsTr().")


if __name__ == "__main__":
    unittest.main()
