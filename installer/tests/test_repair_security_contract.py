import unittest
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
        self.assertIn("MEOARCH_REPAIR_SCOPE", executor)

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
        self.assertIn("/usr/bin/meoarch-repair --live --kiosk", repair_branch)
        self.assertNotIn("--enable-real-install", repair_branch)
        self.assertIn("/usr/bin/cage -s", repair_branch)

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

    def test_live_image_uses_lynis_not_openqa(self):
        packages = {
            line.strip()
            for line in (REPO_ROOT / "meoarch-os/packages.x86_64").read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        }
        self.assertIn("lynis", packages)
        self.assertNotIn("openqa", packages)

    def test_ai_consent_ui_cannot_be_dismissed_implicitly(self):
        qml = REPAIR_QML.read_text(encoding="utf-8")
        self.assertIn("closePolicy: Popup.NoAutoClose", qml)
        self.assertIn("resolveAiConsent(false)", qml)
        self.assertIn("resolveAiConsent(true)", qml)
        self.assertIn("confirmationField.text === root.repairController.confirmationPhrase", qml)

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
