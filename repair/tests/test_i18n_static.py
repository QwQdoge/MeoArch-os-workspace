import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


REPAIR_ROOT = Path(__file__).resolve().parents[1]


class RepairI18nStaticTest(unittest.TestCase):
    def test_consent_destination_fallback_is_friendly_and_localized(self):
        main_qml = (REPAIR_ROOT / "qml/Main.qml").read_text(encoding="utf-8")
        self.assertIn('root.consentSummary.destination || qsTr("Meo Account 服务")', main_qml)
        self.assertNotIn('root.consentSummary.destination || "Meo Account broker"', main_qml)

        catalog = ET.parse(REPAIR_ROOT / "translations/meoarch_repair_en.ts")
        main_context = next(
            context for context in catalog.findall("context")
            if context.findtext("name") == "Main"
        )
        translations = {
            message.findtext("source"): message.findtext("translation")
            for message in main_context.findall("message")
        }
        self.assertEqual(translations.get("Meo Account 服务"), "Meo Account service")
        self.assertEqual(translations.get("网络 · 已联网"), "Network · Online")
        self.assertEqual(translations.get("Meo Account · 已连接"), "Meo Account · Connected")
        self.assertEqual(translations.get("检测到系统使用 Limine 引导。"), "Limine boot loader detected.")
        self.assertEqual(
            translations.get("已挂载目标系统的根分区空间已使用至少 90%。"),
            "The mounted target root filesystem is at least 90% full.",
        )
        self.assertEqual(translations.get("设备状态"), "Device status")
        self.assertEqual(
            translations.get("诊断对象 · 当前 Live 环境"),
            "Diagnostic subject · Current Live environment",
        )

        zh_catalog = ET.parse(REPAIR_ROOT / "translations/meoarch_repair_zh_CN.ts")
        repair_context = next(
            context for context in zh_catalog.findall("context")
            if context.findtext("name") == "RepairController"
        )
        zh_translations = {
            message.findtext("source"): message.findtext("translation")
            for message in repair_context.findall("message")
        }
        self.assertEqual(zh_translations.get("The system clock is synchronized through NTP."), "系统时钟已通过 NTP 同步。")
        self.assertEqual(zh_translations.get("Charging"), "充电中")


if __name__ == "__main__":
    unittest.main()
