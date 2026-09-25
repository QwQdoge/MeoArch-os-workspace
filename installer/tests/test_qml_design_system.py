import re
import unittest
import xml.etree.ElementTree as ET
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
            # The Cage handoff must paint an unconditional pure-black first
            # frame before the MeoUI surface is visible. Keep this one narrow
            # boot-only exception explicit instead of weakening the global rule.
            if qml_file.name == "Main.qml":
                self.assertEqual(source.count("Rectangle {"), 1)
                self.assertIn("id: handoffSplash", source)
                self.assertIn('color: "black"', source)
                source = source.replace("Rectangle {", "", 1)
                source = source.replace('color: "black"', "", 1)
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

    def test_all_twelve_installer_pages_reach_the_page_frame(self):
        main = (QML_ROOT / "Main.qml").read_text(encoding="utf-8")
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        for page in (
            "WelcomePage.qml", "LanguageRegionPage.qml", "KeyboardLayoutPage.qml",
            "NetworkPage.qml", "PrivacySecurityPage.qml", "DiskSelectionPage.qml",
            "UserAccountPage.qml", "SoftwarePage.qml", "UpdateChannelPage.qml",
            "SummaryPage.qml", "InstallingPage.qml", "FinishPage.qml",
        ):
            self.assertIn(page, main)
        self.assertIn("pageCount: root.pages.length", main)
        self.assertIn("property int pageCount: 12", frame)

    def test_startup_is_localized_fail_closed_and_visually_minimal(self):
        host = (QML_ROOT.parent / "app/main.cpp").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
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
        # The readiness card is a fixed four-row model. A bounded Repeater is
        # acceptable here; unbounded/dynamic startup content is not.
        self.assertIn('Accessible.name: qsTr("Live environment check")', welcome)
        for label in ("Environment", "Network", "Hardware", "Meo Account"):
            self.assertIn('qsTr("' + label + '")', welcome)
        self.assertNotIn("ListView", welcome)
        self.assertNotIn("Loader", welcome)
        self.assertIn('qsTr("Review first. Nothing changes until you confirm.")', welcome)
        self.assertLess(
            host.index("loadCatalogs(initialUiLanguage);"),
            host.index("InstallerController controller(arguments);"),
        )
        self.assertIn("controller.retranslateUserFacingState();", host)
        self.assertIn("void InstallerController::retranslateUserFacingState()", controller)

    def test_power_dialog_uses_md_motion_and_hold_confirmation(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        self.assertIn("presentation: MeoMotionPopup.Dialog", frame)
        self.assertEqual(frame.count("MeoHoldToConfirm {"), 2)
        self.assertIn('confirmationText: qsTr("Hold to restart")', frame)
        self.assertIn('confirmationText: qsTr("Hold to shut down")', frame)
        self.assertIn("holdDuration: 1200", frame)
        self.assertIn("KeyNavigation.down: shutdownAction", frame)

    def test_top_actions_are_compact_borderless_and_help_is_step_local(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        actions_start = frame.index("id: actions")
        actions_end = frame.index("MeoMotionPopup {", actions_start)
        actions = frame[actions_start:actions_end]

        self.assertIn('readonly property string topActionSize: "s"', frame)
        self.assertIn('readonly property string topActionType: "standard"', frame)
        self.assertEqual(actions.count("size: frame.topActionSize"), 4)
        self.assertEqual(actions.count("type: frame.topActionType"), 4)
        self.assertNotIn('size: "l"', actions)
        self.assertNotIn('type: "tonal"', actions)
        for accessible_name in (
            'Accessible.name: qsTr("Open diagnostic console")',
            'Accessible.name: qsTr("Help")',
            'Accessible.name: qsTr("Installer language")',
            'Accessible.name: qsTr("Power")',
        ):
            self.assertIn(accessible_name, actions)

        self.assertIn("readonly property string currentStepHelp", frame)
        self.assertIn("case 5:", frame)
        self.assertIn("case 10:", frame)
        self.assertIn('text: qsTr("Current step")', frame)
        self.assertIn("text: frame.currentStepHelp", frame)
        self.assertIn('text: qsTr("More reference")', frame)
        self.assertIn("helpPopup.openFrom(helpButton)", frame)
        self.assertIn("closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside", frame)

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
        self.assertGreaterEqual(controller.count('QStringLiteral("/usr/bin/timeout")'), 6)
        for deadline in ('QStringLiteral("10s")', 'QStringLiteral("15s")',
                         'QStringLiteral("45s")', 'QStringLiteral("330s")'):
            self.assertIn(deadline, controller)
        self.assertIn("Disk scan timed out", controller)
        self.assertIn("Password hashing timed out", controller)
        self.assertIn("Generating the installation plan timed out", controller)
        self.assertIn("Installation preflight timed out", controller)
        self.assertIn("m_networkHandoffGeneration", header)
        self.assertIn("++m_networkHandoffGeneration", controller)
        self.assertIn("generation != m_networkHandoffGeneration", controller)
        self.assertIn("if (m_hardwareDetecting)", controller)

    def test_custom_profile_persists_required_desktop_and_review_shows_resolved_plan(self):
        software = (QML_ROOT / "pages/SoftwarePage.qml").read_text(encoding="utf-8")
        channel = (QML_ROOT / "pages/UpdateChannelPage.qml").read_text(encoding="utf-8")
        header = (QML_ROOT.parent / "app/installercontroller.h").read_text(encoding="utf-8")
        preview = (QML_ROOT / "PreviewController.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn('value === "custom" ? ["meo-desktop"] : []', software)
        # Profiles are a fixed product contract.  They must be direct page
        # children so a compact Live window cannot omit them from the
        # positioner's layout and strand a user in the catalog below.
        profile_section = software.split('MeoCard {', 1)[0]
        self.assertEqual(profile_section.count('title: qsTr("Recommended")'), 1)
        self.assertEqual(profile_section.count('title: qsTr("Minimal")'), 1)
        self.assertEqual(profile_section.count('title: qsTr("Custom")'), 1)
        self.assertNotIn('Repeater {\n            model: [', profile_section)
        self.assertIn("controller.installPlan.repository", summary)
        self.assertIn("controller.installPlan.package", summary)
        self.assertIn("controller.installPlan.applications", summary)
        self.assertIn("Validated Meo package plan", summary)
        # A generic invokable read is not reactive on its own. Both choice
        # pages must bind through the controller revision so a click updates
        # its indicator and the Custom component controls in the same view.
        self.assertIn("Q_PROPERTY(quint64 selectionRevision", header)
        self.assertIn("property int selectionRevision: 0", preview)
        self.assertIn("++selectionRevision", preview)
        self.assertIn("readonly property var selectionRevision", software)
        self.assertIn("readonly property var selectedComponents", software)
        self.assertEqual(software.count("controlled: true"), 5)
        self.assertIn("readonly property var selectionRevision", channel)

    def test_selection_cards_measure_their_content_column(self):
        selection_card = (QML_ROOT / "components/SelectionCard.qml").read_text(encoding="utf-8")
        self.assertIn("id: copy", selection_card)
        self.assertIn("copy.implicitHeight", selection_card)

    def test_installation_details_keep_multiline_text_in_readable_line_boxes(self):
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn("lineHeightMode: Text.ProportionalHeight", summary)
        self.assertIn("lineHeight: 1.35", summary)

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

    def test_disk_page_uses_detected_capacity_when_enabling_an_erase_plan(self):
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        self.assertIn("controller.disks", disk)
        self.assertIn("detected[index].sizeBytes", disk)
        self.assertIn("transient zero capacity", disk)
        self.assertIn("readonly property real diskSizeBytes", disk)
        self.assertIn("fullDiskMinimumBytes", disk)
        self.assertIn("8 * 1073741824 + 515 * 1048576", disk)
        self.assertIn("guidedMinimumBytes", disk)
        self.assertIn("separateHomeAvailable", disk)
        self.assertIn("Below recommended capacity", disk)
        self.assertIn("Storage unavailable", disk)
        self.assertIn("unavailableReason", disk)
        self.assertIn("hasActiveMappedDescendant", controller)
        self.assertIn("hasProtectedMountedDescendant", controller)
        self.assertIn("protected Live-system mount", controller)
        self.assertIn("Active filesystems, swap, encryption, LVM, RAID, or device-mapper layers", controller)
        self.assertIn("active storage use", controller)

    def test_choice_cards_expose_selection_semantics_without_turning_status_cards_into_buttons(self):
        card = (QML_ROOT / "components/SelectionCard.qml").read_text(encoding="utf-8")
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn("property bool selectionIndicator: false", card)
        self.assertIn("Accessible.RadioButton", card)
        self.assertIn("selectionIndicator: true", disk)
        self.assertIn("Installation plan ready", summary)
        self.assertIn("final erase confirmation", summary)

    def test_summary_names_the_actual_target_for_full_disk_and_partition_confirmation(self):
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")
        self.assertIn("findSelectedDisk", summary)
        self.assertIn("selectedDiskDisplay", summary)
        self.assertIn("The selected root partition will be erased", summary)
        self.assertIn("The selected disk will be erased", summary)
        self.assertIn("Format partition and install", summary)
        self.assertIn("Erase disk and install", summary)
        self.assertIn("Review Summary", installing)
        self.assertIn("Restart the Live session before another installation attempt", installing)

    def test_disk_recovery_exposes_a_non_destructive_rescan_action(self):
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        preview = (QML_ROOT / "PreviewController.qml").read_text(encoding="utf-8")
        self.assertIn("Rescan storage devices", disk)
        self.assertIn("page.controller.refreshDisks()", disk)
        self.assertIn("function refreshDisks()", preview)

    def test_critical_new_safety_copy_has_simplified_chinese_translations(self):
        catalog = ET.parse(QML_ROOT.parent / "translations/meoarch_zh_CN.ts")
        translations = {}
        for context in catalog.findall("context"):
            context_name = context.findtext("name")
            entries = translations.setdefault(context_name, {})
            for message in context.findall("message"):
                entries[message.findtext("source")] = message.findtext("translation")

        required = {
            "SummaryPage": [
                "The selected root partition will be erased",
                "The selected disk will be erased",
                "Format partition and install",
                "All data on %1 will be permanently erased. Existing partitions will not be preserved.",
            ],
            "InstallingPage": [
                "Review Summary",
                "Some disk changes may already have happened. Read the Live diagnostic log, then restart the Live session before another installation attempt. Summary is available for review only.",
            ],
            "NetworkPage": [
                "Offline installation is not available",
                "Connect with Wi-Fi or Ethernet to continue. No disk changes happen on this page or before the final confirmation.",
            ],
            "InstallerController": [
                "The selected software list is invalid. Go back and choose the components again.",
            ],
            "UserAccountPage": ["Finish account details to continue"],
        }
        for context_name, sources in required.items():
            for source in sources:
                self.assertTrue(
                    translations.get(context_name, {}).get(source),
                    f"{context_name}: missing Chinese translation for {source!r}",
                )

    def test_installing_page_explains_verified_progress_and_maps_backend_stage_ids(self):
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parents[0] / "app/installercontroller.cpp").read_text(encoding="utf-8")
        self.assertIn('stage === "preflighting_arch_packages"', installing)
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

    def test_language_page_keeps_timezone_selection_inside_the_cage_only_live_boundary(self):
        page = (QML_ROOT / "pages/LanguageRegionPage.qml").read_text(encoding="utf-8")
        wrapper = (QML_ROOT / "components/MeoTimezoneSelector.qml").read_text(encoding="utf-8")
        packages = (QML_ROOT.parents[1] / "meoarch-os/packages.x86_64").read_text(encoding="utf-8")
        self.assertIn("MeoTimezoneSelector", page)
        self.assertIn("searchable list", wrapper)
        self.assertNotIn("org.kde.plasma.workspace", wrapper)
        self.assertNotIn("KdeTimezoneSelector.qml", wrapper)
        self.assertNotIn("plasma-workspace", packages)
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

    def test_visual_preview_uses_the_same_bilingual_copy_contract(self):
        preview = (QML_ROOT / "PreviewController.qml").read_text(encoding="utf-8")
        catalog = ET.parse(QML_ROOT.parent / "translations/meoarch_zh_CN.ts")
        preview_entries = {}
        for context in catalog.findall("context"):
            if context.findtext("name") == "PreviewController":
                preview_entries = {
                    message.findtext("source"): message.findtext("translation")
                    for message in context.findall("message")
                }
                break
        self.assertIn('Qt.uiLanguage.toLowerCase().startsWith("zh")', preview)
        self.assertIn('summary:qsTr("Open and create compressed archives.")', preview)
        self.assertIn('errorMessage = qsTr("Enter a valid lowercase username.")', preview)
        for source in (
            "Visual preview data",
            "This current network can be remembered after installation.",
            "Open and create compressed archives.",
            "NVMe Solid State Drive",
            "Visual preview complete.",
        ):
            self.assertTrue(preview_entries.get(source), source)

    def test_installer_keeps_cloud_account_authentication_out_of_the_local_user_flow(self):
        user = (QML_ROOT / "pages/UserAccountPage.qml").read_text(encoding="utf-8").casefold()
        self.assertNotIn("meo account", user)
        self.assertNotIn("oauth", user)

    def test_network_handoff_is_explicit_opt_in_and_never_serializes_profile_secrets(self):
        network = (QML_ROOT / "pages/NetworkPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        defaults = (QML_ROOT.parent / "data/default_selections.json").read_text(encoding="utf-8")
        customizer = (QML_ROOT.parent / "backend/apply-target-customizations.sh").read_text(encoding="utf-8")
        self.assertIn("Remember this network after installation", network)
        self.assertIn('"handoffEnabled": false', defaults)
        self.assertIn('value(QStringLiteral("handoffEnabled"), false)', controller)
        self.assertIn("network-handoff.nmconnection", controller)
        self.assertIn("NetworkManager/system-connections", customizer)
        self.assertIn("isSupportedNetworkHandoffProfile", controller)
        self.assertIn('"wpa-psk"', controller)
        self.assertIn('"sae"', controller)
        self.assertIn('"owe"', controller)
        self.assertIn('m_networkState != QStringLiteral("online")', controller)
        self.assertIn('m_networkState != QStringLiteral("repository")', controller)
        self.assertIn("disableNetworkHandoff();", controller)
        self.assertIn("skipOptionalHandoff", controller)
        self.assertIn("installation can continue", controller)
        prepare = controller[controller.index("void InstallerController::prepareInstallation()"):]
        self.assertLess(prepare.index("stageNetworkHandoff()"),
                        prepare.index('setPreflight(QStringLiteral("checking")'))
        self.assertNotIn("sourcePath", defaults)

    def test_network_reachability_separates_public_internet_from_meo_repository(self):
        network = (QML_ROOT / "pages/NetworkPage.qml").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        preflight = (QML_ROOT.parent / "backend/archinstall-preflight.sh").read_text(encoding="utf-8")
        package_preflight = (QML_ROOT.parent / "backend/preflight-arch-packages.sh").read_text(encoding="utf-8")
        self.assertIn("https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db", controller)
        self.assertIn("https://packages.meoarch.org/meo/os/x86_64/meo.db", controller)
        self.assertGreaterEqual(controller.count('setRawHeader("Range", "bytes=0-0")'), 2)
        self.assertIn("m_connectivityManager->get", controller)
        self.assertNotIn("m_connectivityManager->head", controller)
        self.assertIn('QStringLiteral("repository")', controller)
        self.assertIn("readonly property bool hasActiveNetwork", network)
        self.assertIn('networkState !== "no-interface"', network)
        self.assertIn("primaryEnabled: page.hasActiveNetwork", network)
        self.assertIn("without blocking the rest of the setup wizard", network)
        self.assertIn("You can continue setup", network)
        self.assertIn("function onNetworkChanged()", network)
        self.assertIn("connectivityRetry.restart()", network)
        self.assertIn('networkState === "no-interface" ? "error"', network)
        self.assertIn("preflight-arch-packages.sh", preflight)
        self.assertIn("pacman --sync --refresh", package_preflight)
        self.assertIn("pacman --sync --print", package_preflight)
        self.assertNotIn("curl ", package_preflight)
        self.assertNotIn("--head", package_preflight)
        self.assertIn("QRegularExpression::escape(name)", controller)

    def test_cage_uses_embedded_unprivileged_diagnostics_only(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        header = (QML_ROOT.parent / "app/installercontroller.h").read_text(encoding="utf-8")
        controller = (QML_ROOT.parent / "app/installercontroller.cpp").read_text(encoding="utf-8")
        packages = (QML_ROOT.parents[1] / "meoarch-os/packages.x86_64").read_text(encoding="utf-8")
        self.assertIn("Open diagnostic console", frame)
        self.assertIn("runDiagnosticCommand", frame)
        self.assertIn("https://wiki.archlinux.org/title/Installation_guide", frame)
        self.assertIn("https://wiki.archlinux.org/title/Network_configuration", frame)
        self.assertNotIn("Qt.openUrlExternally", frame)
        self.assertIn('QStringLiteral("--reuid=live")', controller)
        self.assertIn('QStringLiteral("--clear-groups")', controller)
        self.assertIn('QStringLiteral("--no-new-privs")', controller)
        self.assertIn('QStringLiteral("/usr/bin/timeout")', controller)
        self.assertIn('QStringLiteral("-i")', controller)
        self.assertNotIn('QStringLiteral("konsole")', controller)
        self.assertNotIn('QStringLiteral("xterm")', controller)
        self.assertNotIn("openDebugTerminal", header)
        self.assertNotIn("\nkonsole\n", f"\n{packages}\n")
        self.assertTrue((QML_ROOT.parents[1] / "assets/wallpapers/installer_background.png").is_file())

    def test_minimum_window_uses_compact_install_and_finish_layouts(self):
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")
        finish = (QML_ROOT / "pages/FinishPage.qml").read_text(encoding="utf-8")
        self.assertIn("page.compactHeight ? page.dp(138)", installing)
        self.assertIn("page.compactHeight ? page.dp(72)", finish)
        self.assertIn('value: qsTr("Available until restart: /tmp/meoarch-installer/logs/install.log")', finish)
        self.assertEqual(finish.count("wrapValue: true"), 2)

    def test_high_scale_chrome_and_installer_components_use_scaled_metrics(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        selector = (QML_ROOT / "components/SelectorDialog.qml").read_text(encoding="utf-8")
        card = (QML_ROOT / "components/SelectionCard.qml").read_text(encoding="utf-8")
        timezone = (QML_ROOT / "components/MeoTimezoneSelector.qml").read_text(encoding="utf-8")
        main = (QML_ROOT / "Main.qml").read_text(encoding="utf-8")
        finish = (QML_ROOT / "pages/FinishPage.qml").read_text(encoding="utf-8")
        installing = (QML_ROOT / "pages/InstallingPage.qml").read_text(encoding="utf-8")

        self.assertIn("readonly property bool compactChrome", frame)
        self.assertIn("visible: !frame.compactChrome", frame)
        self.assertIn("visible: frame.showFooterPageIndicator", frame)
        self.assertIn("height: Math.min(frame.dp(286), frame.height - frame.pageMargin * 2)", frame)
        self.assertIn("function dp(value)", selector)
        self.assertIn("Overlay.overlay.width - dp(48)", selector)
        self.assertIn("highlightMoveDuration: MeoTheme.reduceMotion ? 0", selector)
        self.assertIn("property bool wrapValue: false", card)
        self.assertIn("24 * MeoTheme.globalScale", card)
        self.assertIn("function dp(value)", timezone)
        self.assertIn("size: 32 * MeoTheme.globalScale", main)
        self.assertIn("size: page.dp(48)", finish)
        self.assertIn("id: progressHeader", installing)
        self.assertIn("width: Math.max(0, progressHeader.width - progressValue.width - progressHeader.spacing)", installing)
        self.assertIn("maximumLineCount: 2", installing)

    def test_tall_installer_detail_surfaces_scroll_instead_of_clipping(self):
        frame = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")

        self.assertIn("id: helpFlick", frame)
        self.assertIn("contentHeight: helpContent.implicitHeight", frame)
        self.assertIn("id: advancedFlick", disk)
        self.assertIn("contentHeight: advancedContent.implicitHeight", disk)
        self.assertIn("id: detailsFlick", summary)
        self.assertIn("contentHeight: detailsContent.implicitHeight", summary)
        self.assertIn("wrapMode: Text.WrapAnywhere", summary)
        self.assertIn("id: confirmFlick", summary)
        self.assertIn("contentHeight: confirmContent.implicitHeight", summary)
        self.assertIn("Overlay.overlay.height - page.dp(48)", summary)

    def test_user_visible_static_strings_are_translation_eligible(self):
        offenders = []
        literal = re.compile(r'^\s*(?:text|title|subtitle|label|placeholder):\s*"', re.MULTILINE)
        for qml_file in sorted(QML_ROOT.rglob("*.qml")):
            if literal.search(qml_file.read_text(encoding="utf-8")):
                offenders.append(str(qml_file.relative_to(QML_ROOT)))
        self.assertEqual(offenders, [], "Wrap user-visible QML strings with qsTr().")


if __name__ == "__main__":
    unittest.main()
