import json
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


REPO_ROOT = Path(__file__).parents[2]
CONTROLLER = REPO_ROOT / "installer/app/repaircontroller.cpp"
REPAIR_MAIN = REPO_ROOT / "repair/app/main.cpp"
REPAIR_QML = REPO_ROOT / "repair/qml/Main.qml"


class RepairSecurityContractTests(unittest.TestCase):
    def test_cli_category_accepts_separate_and_inline_values(self):
        source = REPAIR_MAIN.read_text(encoding="utf-8")
        self.assertIn("argument.startsWith(inlinePrefix)", source)
        self.assertIn("argument == option", source)
        self.assertIn(
            'optionValue(arguments, QStringLiteral("--category")',
            source,
        )
        self.assertIn('optionValue(arguments, QStringLiteral("--classify"))', source)
        self.assertIn("org.meo.repair-classification/v1", source)
        self.assertIn('optionValue(arguments, QStringLiteral("--questions"))', source)
        self.assertIn("org.meo.repair-guided-questions/v1", source)
        self.assertIn("|| guidanceRequested || helpRequested", source)

    def test_executor_is_typed_and_does_not_invoke_a_shell(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        executor = source.split("void RepairController::runNextApprovedAction()", 1)[1]
        executor = executor.split("void RepairController::clearPlan()", 1)[0]

        self.assertNotIn("/bin/sh", executor)
        self.assertNotIn("-c\"", executor)
        self.assertNotIn("startDetached", executor)
        self.assertEqual(executor.count("m_executionProcess->start(program, arguments)"), 1)
        self.assertIn("checkScriptPath", executor)
        self.assertIn("actionScriptPath", executor)
        self.assertIn('/usr/bin/pkexec', executor)
        self.assertIn("dispatchPrivilegedServiceAction", executor)
        self.assertIn("capability->privilege", executor)
        self.assertIn("MEOARCH_REPAIR_SCOPE", executor)
        self.assertNotIn("if (m_liveEnvironment) {\n            program = actionScript", executor)
        self.assertIn('/usr/lib/meoarch-repair/live-actions', executor)
        self.assertEqual(executor.count("arguments = {actionScript};"), 1)
        self.assertNotIn('QStringLiteral("--scope")', executor)

    def test_plan_and_review_are_hash_bound_exact_schemas(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn("exactKeys(plan, rootKeys)", source)
        self.assertIn("exactKeys(review, keys)", source)
        self.assertIn("org.meo.repair-plan/v1", source)
        self.assertIn("org.meo.repair-risk-review/v1", source)
        self.assertIn("review.value(QStringLiteral(\"planSha256\")).toString() != m_planSha256", source)
        self.assertIn('QStringLiteral("APPLY REPAIR ") + m_planSha256.left(12).toUpper()', source)

    def test_repair_mode_never_enables_real_install(self):
        kiosk = (REPO_ROOT / "installer/bin/meoarch-installer-kiosk").read_text(encoding="utf-8")
        repair_branch = kiosk.rsplit("repair)", 1)[1].split(";;", 1)[0]
        self.assertIn("/usr/local/bin/meoarch-repair-session", repair_branch)
        self.assertNotIn("--enable-real-install", repair_branch)
        self.assertIn("/usr/bin/cage -s", repair_branch)
        session = (REPO_ROOT / "installer/bin/meoarch-repair-session").read_text(
            encoding="utf-8"
        )
        self.assertIn("/usr/lib/meo-polkit-agent &", session)
        self.assertIn("trap cleanup_agent EXIT HUP INT TERM", session)
        self.assertNotIn("systemctl --user start plasma-polkit-agent.service", session)
        self.assertIn("org.kde.polkit-kde-authentication-agent-1", session)
        self.assertIn("agent_ready", session)
        self.assertIn("/usr/bin/meoarch-repair --live --kiosk", session)

    def test_live_tty_escape_is_explicit_and_cannot_touch_graphical_tty1(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn("m_liveEnvironment && ::geteuid() == 0", source)
        self.assertIn('QStringLiteral("/usr/bin/chvt")', source)
        self.assertIn('QStringLiteral("--property=TTYPath=/dev/tty3")', source)
        self.assertIn('QStringLiteral("getty@tty3.service")', source)
        self.assertIn('QStringLiteral("/usr/bin/chvt"), {QStringLiteral("3")}', source)
        self.assertIn("Do not\n        // touch tty1", source)

    def test_ai_receives_only_structured_diagnostic_findings(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        report_builder = source.split("void RepairController::rebuildAiAuditReport()", 1)[1]
        report_builder = report_builder.split("QString RepairController::knowledgeText(", 1)[0]
        self.assertIn("m_auditFindings", report_builder)
        self.assertNotIn("m_checkLog", report_builder)
        self.assertIn('QStringLiteral("structured_diagnostic_findings")', source)
        self.assertNotIn('QStringLiteral("diagnostic_output")', source)

    def test_storage_and_graphics_checks_have_real_health_signals(self):
        storage = (REPO_ROOT / "repair/checks/storage.sh").read_text(encoding="utf-8")
        graphics = (REPO_ROOT / "repair/checks/graphics.sh").read_text(encoding="utf-8")
        self.assertIn("smartctl -H", storage)
        self.assertIn("nvme smart-log", storage)
        self.assertIn("storage.smart_failed", storage)
        self.assertIn("graphics.nvidia_drm_modeset_disabled", graphics)

    def test_audio_and_display_guided_repairs_are_evidence_first(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        qml = REPAIR_QML.read_text(encoding="utf-8")
        self.assertIn('QStringLiteral("audio")', source)
        self.assertIn('QStringLiteral("display")', source)
        self.assertIn("consumeCheckOutput(chunk)", source)
        self.assertNotIn("parseCheckOutput(m_checkLog)", source)
        self.assertNotIn("readAll()).left(32 * 1024)", source)
        self.assertIn("match.captured(3).left(600)", source)
        self.assertIn("QProcess::FailedToStart", source)
        self.assertIn("actionSupportedByEvidence", source)
        self.assertIn("packages.keyring_unreadable", source)
        self.assertNotIn('codes.contains(QStringLiteral("packages.database_inconsistent"))', source)
        self.assertIn("m_displayRecoverySeconds = 15", source)
        self.assertIn("scheduleDisplayRollback(outputId", source)
        self.assertIn('QStringLiteral("--on-active=20s")', source)
        self.assertIn("cancelDisplayRollback", source)
        self.assertIn("revertDisplayRecovery();", source)
        self.assertIn("found && !stillEnabled", source)
        self.assertIn("rollbackVerified", source)
        self.assertIn("import Meo.System 1.0", qml)
        self.assertIn("SystemState.setDefaultAudioOutput", qml)
        self.assertIn("SystemState.audioMuted = false", qml)
        self.assertIn("classifyProblem(problem)", qml)
        self.assertIn("guidedQuestionsForCategory", qml)
        self.assertIn("setGuidedAnswer", qml)
        self.assertIn("audioGuidedRepairAllowed", qml)
        self.assertIn("displayGuidedRepairAllowed", qml)
        self.assertIn("readonly property bool workflowBusy", qml)
        self.assertIn("m_executionProcess || m_privilegedCallWatcher", source)
        self.assertIn("if (hasBlockingOperation())", source)
        self.assertIn('root.selectedCategory = root.repairController.selectedCategory', qml)
        self.assertIn('audioRecoveryState === "running"', qml)
        self.assertIn('displayRecoveryState === "awaiting_confirmation"', qml)
        main = (REPO_ROOT / "repair/app/main.cpp").read_text(encoding="utf-8")
        self.assertIn('QStringLiteral("--preview-height")', main)
        self.assertIn('QStringLiteral("--evaluate-guidance")', main)
        self.assertIn("automaticDisplayRepairAllowed", main)
        self.assertIn("beginDisplayRecovery", qml)
        self.assertIn("keepDisplayRecovery", qml)

    def test_default_repair_ui_is_grouped_help_shell(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        source = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn("property bool advancedMode: true", qml)
        self.assertIn("MeoSettingsSidebar {", qml)
        self.assertIn("groups: root.helpCategoryGroups", qml)
        self.assertIn("searchResults: root.categorySearchResults(searchText)", qml)
        self.assertIn("function investigateProblem(problem)", qml)
        self.assertIn("function aiReadyForPlan()", qml)
        self.assertIn("root.repairController.requestAiPlan()", qml)
        self.assertIn("visible: false", qml)
        self.assertNotIn('icon.name: "close"', qml)
        self.assertIn("playAudioTestTone", qml)
        self.assertIn('QStringLiteral("/usr/bin/speaker-test")', source)
        tone = source.split("void RepairController::playAudioTestTone()", 1)[1]
        tone = tone.split("bool RepairController::audioServiceRepairAvailable()", 1)[0]
        self.assertNotIn("/bin/sh", tone)
        self.assertIn("process->start(program", tone)

        self.assertIn('root.selectedCategory === "audio"', qml)
        self.assertIn("root.repairController.auditFindings.length === 0", qml)

    def test_help_shell_uses_meoui_page_and_group_patterns(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        self.assertIn("color: MeoTheme.surfaceContainerLow", qml)
        self.assertIn("MeoSettingsSidebar {", qml)
        self.assertIn("MeoGroupedList {", qml)
        self.assertIn('title: qsTr("查找帮助")', qml)
        self.assertIn('searchPlaceholder: qsTr("搜索声音、显示器、网络……")', qml)
        self.assertNotIn('typeRole: "title"; typeSize: "large"', qml)

    def test_package_install_is_a_fixed_omnistore_handoff(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        source = CONTROLLER.read_text(encoding="utf-8")
        registry = (REPO_ROOT / "repair/core/capabilityregistry.cpp").read_text(
            encoding="utf-8"
        )
        self.assertIn('QStringLiteral("open_omnistore_libpulse")', registry)
        self.assertIn('QStringLiteral("open_omnistore_wireplumber")', registry)
        self.assertIn('QStringLiteral("open_omnistore_bluez_utils")', registry)
        self.assertIn('QStringLiteral("/usr/bin/omnistore")', source)
        self.assertIn('QStringLiteral("install")', source)
        self.assertIn('QStringLiteral("--source")', source)
        self.assertIn('QStringLiteral("native")', source)
        self.assertIn('codes.contains(QStringLiteral("audio.pactl_missing"))', source)
        self.assertIn('setExecution(QStringLiteral("handoff")', source)
        self.assertIn("Finish or cancel there, then return and run the check again.", source)
        executor = source.split("void RepairController::runNextApprovedAction()", 1)[1]
        executor = executor.split("void RepairController::clearPlan()", 1)[0]
        self.assertNotIn("startDetached", executor)
        self.assertNotIn("omnistore install", qml)

    def test_audio_session_changes_have_bounded_async_post_checks(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        self.assertIn("property int audioPostCheckAttempts: 0", qml)
        self.assertIn("root.audioPostCheckAttempts < 5", qml)
        self.assertIn("SystemState.operationBusy", qml)
        self.assertIn("SystemState.operationError", qml)
        self.assertIn("SystemState.clearOperationError()", qml)
        self.assertIn("没有继续更改其他设置", qml)

    def test_simple_wizard_connects_ai_plan_to_one_click_repair(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        source = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn('root.wizardStage = "ai_planning"', qml)
        self.assertIn("root.repairController.requestAiPlan()", qml)
        self.assertIn('root.wizardStage = "repair_approval"', qml)
        self.assertIn("AI 已找到可执行的修复", qml)
        self.assertIn("同意并修复", qml)
        self.assertIn(
            "root.repairController.executeConfirmedPlan(root.repairController.confirmationPhrase)",
            qml,
        )
        self.assertIn("wizardPlanHasWriteAction", qml)
        self.assertIn("function findingLabel(finding)", qml)
        self.assertIn("function actionLabel(kind)", qml)
        self.assertIn("将执行：%1", qml)
        self.assertIn('previewWizardStage === "repair-approval"', qml)
        main = (REPO_ROOT / "repair/app/main.cpp").read_text(encoding="utf-8")
        self.assertIn('QStringLiteral("--preview-workflow")', main)
        self.assertIn('root.repairController.executionState === "complete"', qml)
        self.assertIn("问题现在解决了吗？", qml)
        self.assertIn('QStringLiteral("rebuild_initramfs")', source)
        self.assertIn('QStringLiteral("reload_systemd_manager")', source)
        self.assertIn('QStringLiteral("boot.initramfs_missing")', source)
        self.assertIn('QStringLiteral("boot.manager_reload_needed")', source)

    def test_ai_flow_smoke_uses_loopback_and_isolated_write_action(self):
        smoke = (REPO_ROOT / "repair/tests/ai-flow-smoke.cpp").read_text(
            encoding="utf-8"
        )
        self.assertIn("QTcpServer", smoke)
        self.assertIn("QHostAddress::LocalHost", smoke)
        self.assertIn("controller.resolveAiConsent(true)", smoke)
        self.assertIn("controller.confirmationPhrase()", smoke)
        self.assertIn('QStringLiteral("restart_network_manager")', smoke)
        self.assertIn("MEOARCH_WRITE_ACTION_OK", smoke)
        self.assertIn("FakePrivilegedRepairService", smoke)
        self.assertIn('QStringLiteral("org.meo.Repair1")', smoke)
        self.assertIn("consents == 2", smoke)
        self.assertIn("providerRequests == 2", smoke)
        self.assertIn("QTemporaryDir settingsRoot", smoke)
        self.assertIn("QSettings::setPath", smoke)
        self.assertIn("All confirmed allowlisted actions finished.", smoke)
        harness = (
            REPO_ROOT / "repair/tests/run-ai-write-flow-smoke.sh"
        ).read_text(encoding="utf-8")
        self.assertIn("--unshare-all", harness)
        self.assertIn("--ro-bind / /", harness)
        self.assertIn('mkdir -p "${fixture_root}/tmp"', harness)
        self.assertIn('--setenv TMPDIR "${fixture_root}/tmp"', harness)
        self.assertIn('MEO_FINDING|warning|network.manager_inactive', harness)
        self.assertIn("DBUS_SYSTEM_BUS_ADDRESS", harness)
        self.assertIn("dbus-run-session", harness)
        self.assertIn('grep -qxF MEOARCH_WRITE_ACTION_OK', harness)
        cmake = (REPO_ROOT / "repair/CMakeLists.txt").read_text(encoding="utf-8")
        self.assertIn("meoarch-repair-ai-flow-smoke", cmake)
        acceptance = (REPO_ROOT / "scripts/acceptance/20-build-components.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("run-ai-write-flow-smoke.sh", acceptance)
        self.assertIn("repair-ai-flow-smoke.log", acceptance)
        audio_gate = acceptance.split("--questions=audio", 1)[1].split(
            "--questions=display", 1
        )[0]
        self.assertIn('assert d["questions"]', audio_gate)
        self.assertIn('len(q["options"]) == 2', audio_gate)
        self.assertNotIn('len(d["questions"]) == 2', audio_gate)

        iso_inspection = (
            REPO_ROOT / "scripts/acceptance/40-inspect-iso.sh"
        ).read_text(encoding="utf-8")
        for runbook in (
            "system-general.json",
            "audio-output.json",
            "display-output.json",
            "network-connectivity.json",
            "boot-startup.json",
            "package-health.json",
            "storage-health.json",
            "graphics-session.json",
            "security-posture.json",
        ):
            self.assertIn(runbook, iso_inspection)

    def test_local_knowledge_pack_has_versioned_safe_runbooks(self):
        knowledge = REPO_ROOT / "repair/knowledge"
        manifest = json.loads((knowledge / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["schema"], "org.meo.help-knowledge-manifest/v1")
        self.assertRegex(manifest["version"], r"^\d{4}\.\d{2}\.\d{2}\.\d+$")
        runbook_files = (
            "system-general.json",
            "audio-output.json",
            "display-output.json",
            "network-connectivity.json",
            "boot-startup.json",
            "package-health.json",
            "storage-health.json",
            "graphics-session.json",
            "security-posture.json",
        )
        manifest_paths = {
            resource["path"]
            for resource in manifest["resources"]
            if resource["kind"] == "runbook"
        }
        self.assertEqual(manifest_paths, set(runbook_files))
        for filename in runbook_files:
            with self.subTest(filename=filename):
                runbook = json.loads((knowledge / filename).read_text(encoding="utf-8"))
                self.assertEqual(runbook["schema"], "org.meo.help-runbook/v1")
                self.assertTrue(runbook["diagnostics"])
                self.assertTrue(runbook["manualHandoffs"])
                self.assertTrue(runbook["questions"])
                for question in runbook["questions"]:
                    self.assertTrue(question["label"])
                    self.assertTrue(question["options"])
                    self.assertEqual(len(question["options"]), 2)
                    for option in question["options"]:
                        self.assertEqual(set(option), {"id", "label"})
                for capability in runbook["guidedCapabilities"]:
                    self.assertTrue(capability["reversible"])
                    self.assertTrue(capability["postCheck"])
                    if capability["id"] == "display.enable_connected":
                        self.assertEqual(capability["rollbackAuthority"], "systemd-user-timer")
        prompt = (knowledge / "system-prompt.md").read_text(encoding="utf-8")
        self.assertIn("Never request an administrator password", prompt)
        self.assertIn("timed automatic rollback", prompt)
        self.assertIn("post-check", prompt)
        self.assertIn("not repair-plan action kinds", prompt)
        self.assertIn("allowedRepairActions", prompt)
        self.assertIn("Do not repeat a diagnostic inspection", prompt)
        self.assertIn("in the user's language", prompt)
        controller = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn('QStringLiteral("guided_answer=%1|%2")', controller)
        self.assertIn('QStringLiteral("guided_answers")', controller)
        self.assertIn("No previous category result is being reused", controller)
        self.assertIn("m_userProblem.clear();", controller)
        for filename in runbook_files:
            self.assertIn(f'QStringLiteral("{filename}")', controller)

    def test_boot_repairs_have_specific_findings_and_post_checks(self):
        check = (REPO_ROOT / "repair/checks/boot.sh").read_text(encoding="utf-8")
        controller = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn("boot.initramfs_missing", check)
        self.assertIn("boot.manager_reload_needed", check)
        self.assertIn("NeedDaemonReload", check)
        self.assertIn("-size +0c", check)
        self.assertIn("boot.target_boot_not_mounted", check)
        self.assertIn("boot.boot_not_mounted", check)
        self.assertIn("findmnt -rn /mnt/boot", check)
        self.assertIn("findmnt -rn /boot", check)
        self.assertIn(
            'codes.contains(QStringLiteral("boot.initramfs_missing"))', controller
        )
        self.assertIn(
            'codes.contains(QStringLiteral("boot.manager_reload_needed"))', controller
        )
        self.assertIn("return !m_liveEnvironment", controller)

    def test_audio_diagnostics_detect_stale_saved_default(self):
        source = (REPO_ROOT / "repair/checks/audio.sh").read_text(encoding="utf-8")
        for finding in (
            "audio.pipewire_inactive",
            "audio.pipewire_pulse_inactive",
            "audio.wireplumber_inactive",
        ):
            self.assertIn(finding, source)
        self.assertIn("wpctl status", source)
        self.assertIn("audio.saved_default_missing", source)
        self.assertIn("audio.no_physical_outputs", source)
        self.assertIn("auto_)?null", source)
        controller = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn('QStringLiteral("--user"), QStringLiteral("restart")', controller)
        self.assertIn("beginAudioOutputPostCheck", controller)
        self.assertIn('QStringLiteral("list"), QStringLiteral("short")', controller)
        self.assertIn("isPlaceholderAudioSink", controller)
        self.assertIn("m_audioOutputPostCheckAttempts < 4", controller)
        self.assertIn('m_audioRecoveryState == QStringLiteral("running")', controller)
        restart = controller.split("void RepairController::restartAudioServices()", 1)[1]
        restart = restart.split("void RepairController::beginAudioServicePostCheck()", 1)[0]
        self.assertNotIn("waitForFinished", restart)

    def test_privileged_action_scripts_have_fixed_post_checks(self):
        for path in (REPO_ROOT / "repair/actions").glob("*.sh"):
            with self.subTest(path=path.name):
                source = path.read_text(encoding="utf-8")
                self.assertIn("Post-check passed:", source)
                self.assertIn('--scope)', source)
                self.assertIn('--target-root)', source)
                self.assertIn('[ "${target_root}" = "/mnt" ]', source)
                self.assertIn('case "${scope}" in live|system)', source)

        live_actions = REPO_ROOT / "repair/live-actions"
        expected = {path.name for path in (REPO_ROOT / "repair/actions").glob("*.sh")}
        self.assertEqual({path.name for path in live_actions.glob("*.sh")}, expected)
        for path in live_actions.glob("*.sh"):
            with self.subTest(live_path=path.name):
                source = path.read_text(encoding="utf-8")
                self.assertIn('[ "$#" -eq 0 ]', source)
                self.assertIn('[ "$(id -u)" -eq 0 ]', source)
                self.assertIn("--scope live --target-root /mnt", source)
                self.assertNotIn("--scope system", source)

    def test_polkit_policy_and_typed_privileged_service_are_action_specific(self):
        policy = REPO_ROOT / "repair/data/org.meo.repair.policy"
        root = ET.parse(policy).getroot()
        actions = root.findall("action")
        self.assertEqual(len(actions), 4)
        for action in actions:
            with self.subTest(action=action.attrib["id"]):
                self.assertIsNone(action.find("annotate"))
                self.assertEqual(action.find("defaults/allow_any").text, "no")
                self.assertNotIn("password", "".join(action.itertext()).lower())

        service = (REPO_ROOT / "repair/privileged/privilegedrepairservice.cpp").read_text(
            encoding="utf-8"
        )
        header = (REPO_ROOT / "repair/privileged/privilegedrepairservice.h").read_text(
            encoding="utf-8"
        )
        for method in (
            "ReloadSystemdManager()",
            "RestartNetworkManager()",
            "RebuildInitramfs()",
            "RefreshPacmanKeyring()",
        ):
            self.assertIn(method, header)
        self.assertNotIn("Execute(", header)
        self.assertIn("SystemBusNameSubject", service)
        self.assertIn("checkAuthorizationSync", service)
        self.assertIn("AllowUserInteraction", service)
        self.assertNotIn("QProcessEnvironment::systemEnvironment", service)

        live_policy = REPO_ROOT / "repair/data/org.meo.repair-live.policy"
        live_root = ET.parse(live_policy).getroot()
        live_actions = live_root.findall("action")
        self.assertEqual(len(live_actions), 4)
        live_paths = {}
        for action in live_actions:
            with self.subTest(live_action=action.attrib["id"]):
                self.assertTrue(action.attrib["id"].startswith("org.meo.repair.live."))
                path = action.find("annotate").text
                self.assertRegex(
                    path,
                    r"^/usr/lib/meoarch-repair/live-actions/[a-z-]+\.sh$",
                )
                self.assertEqual(action.find("defaults/allow_any").text, "no")
                self.assertEqual(action.find("defaults/allow_inactive").text, "no")
                self.assertEqual(action.find("defaults/allow_active").text, "no")
                live_paths[action.attrib["id"]] = path

        live_rule = (REPO_ROOT / "repair/data/org.meo.repair-live.rules").read_text(
            encoding="utf-8"
        )
        for action_id, path in live_paths.items():
            self.assertIn(f'"{action_id}": "{path}"', live_rule)
        self.assertEqual(live_rule.count('"org.meo.repair.live.'), len(live_paths))
        self.assertIn('action.lookup("program") === fixedLiveActions[action.id]', live_rule)
        self.assertIn('action.lookup("user") === "root"', live_rule)
        self.assertIn('subject.user === "live"', live_rule)
        self.assertIn('subject.local === true', live_rule)
        self.assertIn('subject.active === true', live_rule)
        self.assertIn("polkit.Result.YES", live_rule)
        self.assertNotIn("polkit.spawn", live_rule)
        repair_cmake = (REPO_ROOT / "repair/CMakeLists.txt").read_text(encoding="utf-8")
        self.assertNotIn("org.meo.repair-live.rules", repair_cmake)
        self.assertNotIn("org.meo.repair-live.policy", repair_cmake)
        self.assertNotIn("live-actions", repair_cmake)

        shadow = (REPO_ROOT / "meoarch-os/airootfs/etc/shadow").read_text(
            encoding="utf-8"
        )
        locked_users = {
            line.split(":", 2)[0]: line.split(":", 2)[1]
            for line in shadow.splitlines()
            if line.startswith(("root:", "live:"))
        }
        self.assertEqual(locked_users, {"root": "*", "live": "*"})

    def test_boot_menus_expose_install_and_repair_modes(self):
        boot_files = (
            "meoarch-os/grub/grub.cfg",
            "meoarch-os/grub/loopback.cfg",
            "meoarch-os/syslinux/archiso_sys-linux.cfg",
        )
        for relative in boot_files:
            with self.subTest(relative=relative):
                source = (REPO_ROOT / relative).read_text(encoding="utf-8")
                self.assertIn("meoarch.mode=install", source)
                self.assertIn("meoarch.mode=repair", source)
                self.assertIn("meoarch.mode=console", source)
                self.assertIn("systemd.unit=multi-user.target", source)

    def test_repair_scope_is_explicit_and_connection_state_is_local(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        header = (REPO_ROOT / "installer/app/repaircontroller.h").read_text(encoding="utf-8")
        qml = REPAIR_QML.read_text(encoding="utf-8")
        aggregate = (REPO_ROOT / "repair/checks/all.sh").read_text(encoding="utf-8")
        packages = (REPO_ROOT / "repair/checks/packages.sh").read_text(encoding="utf-8")
        network = (REPO_ROOT / "repair/checks/network.sh").read_text(encoding="utf-8")

        self.assertIn("Q_PROPERTY(QString repairScope", header)
        self.assertIn("Q_PROPERTY(bool mountedTargetAvailable", header)
        self.assertIn("Q_PROPERTY(QString networkConnectionState", header)
        self.assertIn("Q_PROPERTY(QString accountConnectionState", header)
        self.assertIn("org.freedesktop.NetworkManager", source)
        self.assertIn("Connectivity", source)
        self.assertIn("mountedTargetAvailable", qml)
        self.assertIn("accountConnectionState", qml)
        self.assertIn("networkConnectionState", qml)
        self.assertIn("Diagnostic subject: Live Environment", aggregate)
        self.assertIn("Diagnostic subject: Mounted Installed System", aggregate)
        self.assertIn('MEOARCH_REPAIR_SCOPE:-system}" = "live"', packages)
        self.assertIn("network.captive_portal", network)
        self.assertIn("network.limited_connectivity", network)
        self.assertIn("ip -6 route show", network)

    def test_console_getty_is_conditioned_on_explicit_boot_mode(self):
        getty = (
            REPO_ROOT
            / "meoarch-os/airootfs/etc/systemd/system/getty@tty1.service.d/10-meoarch-console.conf"
        ).read_text(encoding="utf-8")
        service = (
            REPO_ROOT / "meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service"
        ).read_text(encoding="utf-8")
        self.assertIn("ConditionKernelCommandLine=meoarch.mode=console", getty)
        self.assertIn("--autologin root", getty)
        self.assertNotIn("ExecStartPost=/usr/lib/meoarch/meo-boot-status stage ready", service)
        self.assertIn("meoarch.mode=console", service)

    def test_live_image_uses_lynis_not_openqa(self):
        packages = {
            line.strip()
            for line in (REPO_ROOT / "meoarch-os/packages.x86_64").read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        }
        self.assertIn("lynis", packages)
        self.assertTrue({"alsa-utils", "pipewire-audio", "pipewire-pulse", "wireplumber"} <= packages)
        self.assertIn("polkit-qt6", packages)
        self.assertNotIn("libplasma", packages)
        self.assertNotIn("openqa", packages)
        inspection = (REPO_ROOT / "scripts/acceptance/40-inspect-iso.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("libmeosystemplugin.so", inspection)
        self.assertIn("libPlasma\\.so\\.7|libkrdb\\.so", inspection)
        self.assertIn('cmp "${repo_root}/repair/knowledge/${path}"', inspection)
        live_plugin = (REPO_ROOT / "installer/live-system/meosystemliveplugin.cpp").read_text(
            encoding="utf-8"
        )
        self.assertIn("qmlRegisterSingletonType<SystemStateHub>", live_plugin)
        self.assertNotIn("DynamicColorProvider", live_plugin)
        self.assertNotIn("DesktopWidgetBridge", live_plugin)
        live_cmake = (REPO_ROOT / "installer/live-system/CMakeLists.txt").read_text(
            encoding="utf-8"
        )
        self.assertIn("find_package(KF6I18n REQUIRED)", live_cmake)
        self.assertIn("KF6::I18n", live_cmake)

        target_config = (REPO_ROOT / "installer/backend/generate-config.py").read_text(
            encoding="utf-8"
        )
        for package in ("alsa-utils", "pipewire-audio", "pipewire-pulse", "wireplumber"):
            self.assertIn(f'"{package}"', target_config)

        kiosk = (REPO_ROOT / "installer/bin/meoarch-installer-kiosk").read_text(
            encoding="utf-8"
        )
        service = (REPO_ROOT / "meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service").read_text(
            encoding="utf-8"
        )
        self.assertIn('systemctl start "user-runtime-dir@${live_uid}.service"', kiosk)
        self.assertIn("/usr/bin/runuser -u live", kiosk)
        self.assertIn('DBUS_SESSION_BUS_ADDRESS="unix:path=${live_runtime}/bus"', kiosk)
        self.assertIn("ExecStartPre=/usr/bin/usermod -aG audio,seat,tty live", service)
        session = (REPO_ROOT / "installer/bin/meoarch-repair-session").read_text(
            encoding="utf-8"
        )
        self.assertIn("/usr/lib/meo-polkit-agent &", session)
        self.assertIn("org.kde.polkit-kde-authentication-agent-1", session)

    def test_ai_consent_ui_cannot_be_dismissed_implicitly(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        self.assertIn("closePolicy: Popup.NoAutoClose", qml)
        self.assertIn("resolveAiConsent(false)", qml)
        self.assertIn("resolveAiConsent(true)", qml)
        self.assertIn("confirmationField.text === root.repairController.confirmationPhrase", qml)

    def test_repair_language_actions_use_an_explicit_qml_property(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        self.assertIn("required property var uiLanguageController", qml)
        self.assertIn("root.uiLanguageController.select(\"system\")", qml)
        self.assertIn("root.uiLanguageController.select(\"zh_CN\")", qml)
        self.assertIn("root.uiLanguageController.select(\"en_US\")", qml)
        self.assertNotIn("function() { UiLanguageController.select", qml)
        self.assertIn(
            'QStringLiteral("uiLanguageController"), QVariant::fromValue(&languageController)',
            REPAIR_MAIN.read_text(encoding="utf-8"),
        )

    def test_local_keys_have_no_plaintext_fallback_and_are_read_after_consent(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn("setInsecureFallback(false)", source)
        self.assertNotIn("setInsecureFallback(true)", source)
        consent = source.index("void RepairController::resolveAiConsent")
        key_read = source.index("new QKeychain::ReadPasswordJob")
        self.assertGreater(key_read, consent)
        for endpoint in (
            "https://api.openai.com/v1/responses",
            "https://generativelanguage.googleapis.com/v1beta/models/",
            "https://api.deepseek.com/chat/completions",
            "https://openrouter.ai/api/v1/chat/completions",
        ):
            self.assertIn(endpoint, source)
        self.assertIn('QStringLiteral("store"), false', source)
        self.assertIn('{QStringLiteral("destination"), destination.toString(QUrl::FullyEncoded)}', source)
        self.assertIn('currentHash != m_pendingConsent.value(QStringLiteral("payloadSha256"))', source)
        self.assertIn('QStringLiteral("provider/%1").arg(provider)', source)
        self.assertIn('m_sessionCredentialProvider == provider', source)

    def test_account_consent_destination_matches_credential_metadata(self):
        source = CONTROLLER.read_text(encoding="utf-8")
        self.assertIn("accountProviderUrl(", source)
        self.assertIn(
            "destination.toString(QUrl::FullyEncoded)\n"
            "                == expectedDestination.toString(QUrl::FullyEncoded)",
            source,
        )
        self.assertIn('QStringLiteral("endpoint")', source)

    def test_diagnostic_and_action_scripts_are_fixed_and_ai_key_free(self):
        scripts = list((REPO_ROOT / "repair/checks").glob("*.sh"))
        scripts += list((REPO_ROOT / "repair/actions").glob("*.sh"))
        self.assertGreaterEqual(len(scripts), 11)
        for path in scripts:
            with self.subTest(path=path.name):
                source = path.read_text(encoding="utf-8")
                self.assertTrue(source.startswith("#!/usr/bin/env bash\n"))
                self.assertNotIn("OPENAI_API_KEY", source)
                self.assertNotIn("OMNISTORE_AI_API_KEY", source)


if __name__ == "__main__":
    unittest.main()
