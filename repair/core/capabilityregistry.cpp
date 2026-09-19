#include "capabilityregistry.h"

namespace MeoRepair {

QString CapabilityRegistry::policyVersion()
{
    return QStringLiteral("org.meo.repair-policy/2026.09.17.2");
}

const QVector<Capability> &CapabilityRegistry::all()
{
    // Risk presentation, privilege and reversibility are deliberately
    // independent. The model never supplies or overrides these values.
    static const QVector<Capability> capabilities{
        {QStringLiteral("run_lynis_audit"), QStringLiteral("security"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("local"), {}, {}, true},
        {QStringLiteral("verify_package_files"), QStringLiteral("packages"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("local"), {}, {}, true},
        {QStringLiteral("inspect_audio_state"), QStringLiteral("audio"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("minimal"), {}, {}, true},
        {QStringLiteral("inspect_display_state"), QStringLiteral("display"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("minimal"), {}, {}, true},
        {QStringLiteral("inspect_boot_state"), QStringLiteral("boot"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("minimal"), {}, {}, true},
        {QStringLiteral("inspect_network_state"), QStringLiteral("network"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("minimal"), {}, {}, true},
        {QStringLiteral("inspect_storage_state"), QStringLiteral("storage"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("minimal"), {}, {}, true},
        {QStringLiteral("inspect_graphics_state"), QStringLiteral("graphics"),
         QStringLiteral("read"), QStringLiteral("user"), QStringLiteral("automatic"),
         QStringLiteral("minimal"), {}, {}, true},
        {QStringLiteral("restart_network_manager"), QStringLiteral("network"),
         QStringLiteral("session"), QStringLiteral("system"), QStringLiteral("automatic"),
         QStringLiteral("never"), {}, {QStringLiteral("network.manager"),
                                        QStringLiteral("network.routes"),
                                        QStringLiteral("network.resolver")}, true},
        {QStringLiteral("refresh_pacman_keyring"), QStringLiteral("packages"),
         QStringLiteral("persistent"), QStringLiteral("system"), QStringLiteral("manual"),
         QStringLiteral("never"), {}, {QStringLiteral("packages.keyring")}, true},
        {QStringLiteral("rebuild_initramfs"), QStringLiteral("boot"),
         QStringLiteral("persistent"), QStringLiteral("system"), QStringLiteral("manual"),
         QStringLiteral("never"), {}, {QStringLiteral("boot.initramfs")}, true},
        {QStringLiteral("reload_systemd_manager"), QStringLiteral("boot"),
         QStringLiteral("session"), QStringLiteral("system"), QStringLiteral("automatic"),
         QStringLiteral("never"), {}, {QStringLiteral("boot.systemd_manager")}, true},
        // These capabilities only open an OmniStore-owned confirmation. The
        // model cannot provide a package identifier, source, or argument.
        {QStringLiteral("open_omnistore_libpulse"), QStringLiteral("audio"),
         QStringLiteral("persistent"), QStringLiteral("user"), QStringLiteral("manual"),
         QStringLiteral("never"), {}, {QStringLiteral("audio.pactl")}, true},
        {QStringLiteral("open_omnistore_wireplumber"), QStringLiteral("audio"),
         QStringLiteral("persistent"), QStringLiteral("user"), QStringLiteral("manual"),
         QStringLiteral("never"), {}, {QStringLiteral("audio.wpctl")}, true},
        {QStringLiteral("open_omnistore_bluez_utils"), QStringLiteral("audio"),
         QStringLiteral("persistent"), QStringLiteral("user"), QStringLiteral("manual"),
         QStringLiteral("never"), {}, {QStringLiteral("audio.bluetoothctl")}, true},
        // Deliberately non-executable first-release boundaries.
        {QStringLiteral("storage_destructive_repair"), QStringLiteral("storage"),
         QStringLiteral("destructive"), QStringLiteral("system"), QStringLiteral("none"),
         QStringLiteral("never"), {}, {}, false},
        {QStringLiteral("graphics_driver_change"), QStringLiteral("graphics"),
         QStringLiteral("persistent"), QStringLiteral("system"), QStringLiteral("manual"),
         QStringLiteral("never"), {}, {}, false},
        {QStringLiteral("security_incident_remediation"), QStringLiteral("security"),
         QStringLiteral("persistent"), QStringLiteral("system"), QStringLiteral("none"),
         QStringLiteral("never"), {}, {}, false},
    };
    return capabilities;
}

const Capability *CapabilityRegistry::find(const QString &id)
{
    for (const Capability &capability : all()) {
        if (capability.id == id)
            return &capability;
    }
    return nullptr;
}

} // namespace MeoRepair
