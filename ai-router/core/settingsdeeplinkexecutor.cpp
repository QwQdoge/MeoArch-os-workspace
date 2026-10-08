#include "settingsdeeplinkexecutor.h"

#include <QProcess>
#include <QSet>
#include <QStandardPaths>

namespace MeoAi {

CapabilityResult SettingsDeepLinkExecutor::execute(const Capability &capability,
                                                   const CapabilityRequest &request)
{
    Q_UNUSED(request)

    const QString route = capability.fixedArguments.value(QStringLiteral("route")).toString();
    static const QSet<QString> allowedRoutes{
        QStringLiteral("wifi"),
        QStringLiteral("bluetooth"),
        QStringLiteral("sound"),
        QStringLiteral("display"),
        QStringLiteral("appearance"),
    };

    if (!allowedRoutes.contains(route)) {
        return {false, QStringLiteral("failed"), QStringLiteral("route_not_allowlisted"),
                QStringLiteral("The compiled Settings route is not allowlisted."),
                capability.id, {}, false};
    }

    const QString program = QStandardPaths::findExecutable(QStringLiteral("meo-settings"));
    if (program.isEmpty()) {
        return {false, QStringLiteral("unavailable"), QStringLiteral("settings_unavailable"),
                QStringLiteral("Meo Settings is not installed or is not available in PATH."),
                capability.id, {}, false};
    }

    const bool started = QProcess::startDetached(program,
                                                  {QStringLiteral("--route"), route});
    if (!started) {
        return {false, QStringLiteral("failed"), QStringLiteral("launch_failed"),
                QStringLiteral("Meo Settings could not be launched."),
                capability.id, {}, false};
    }

    return {true, QStringLiteral("ok"), QStringLiteral("launched"),
            QStringLiteral("Meo Settings accepted the typed route launch request."),
            capability.id,
            {{QStringLiteral("owner"), capability.owner},
             {QStringLiteral("route"), route}},
            false};
}

} // namespace MeoAi
