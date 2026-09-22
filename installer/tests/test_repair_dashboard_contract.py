import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HEADER = ROOT / "installer/app/repaircontroller.h"
CPP = ROOT / "installer/app/repaircontroller.cpp"
QML = ROOT / "repair/qml/Main.qml"


class RepairDashboardContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.header = HEADER.read_text(encoding="utf-8")
        cls.cpp = CPP.read_text(encoding="utf-8")
        cls.qml = QML.read_text(encoding="utf-8")

    def test_controller_exposes_lightweight_health_states(self):
        for name in (
            "storageHealthState",
            "bootHealthState",
            "timeHealthState",
            "powerHealthState",
        ):
            self.assertIn(f"Q_PROPERTY(QString {name}", self.header)

    def test_health_probes_are_read_only_and_local(self):
        for marker in (
            "QStorageInfo",
            'QStringLiteral("--failed")',
            'QStringLiteral("NTPSynchronized")',
            'QStringLiteral("/sys/class/power_supply")',
        ):
            self.assertIn(marker, self.cpp)

        refresh = self.cpp.split(
            "void RepairController::refreshEnvironmentState()", 1
        )[1].split("QUrl RepairController::authUrl", 1)[0]
        for forbidden in (
            "pacman -S",
            "mount ",
            "umount ",
            "systemctl restart",
            "systemctl enable",
            "nmcli connection up",
        ):
            self.assertNotIn(forbidden, refresh)

    def test_dashboard_contains_realtime_and_controller_states(self):
        self.assertIn("function overviewCards()", self.qml)
        self.assertIn('text: qsTr("设备状态")', self.qml)
        for marker in (
            "SystemState.audioAvailable",
            "networkConnectionState",
            "accountConnectionState",
            "storageHealthState",
            "bootHealthState",
            "timeHealthState",
            "powerHealthState",
        ):
            self.assertIn(marker, self.qml)

    def test_diagnostic_scope_metadata_reaches_qml(self):
        self.assertIn('"scope": categories[index].scope || "system"', self.qml)
        self.assertIn('if (scope === "target")', self.qml)
        self.assertIn('if (scope === "live")', self.qml)
        self.assertIn('if (scope === "mixed")', self.qml)

    def test_dashboard_routes_to_existing_diagnostics(self):
        for category in (
            '"category": "network"',
            '"category": "audio"',
            '"category": "display"',
            '"category": "storage"',
            '"category": "boot"',
            '"category": "security"',
        ):
            self.assertIn(category, self.qml)
        self.assertIn(
            "root.chooseCategory(healthCard.modelData.category)", self.qml
        )


if __name__ == "__main__":
    unittest.main()
