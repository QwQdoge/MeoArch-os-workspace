#include "privilegedrepairservice.h"

#include <QFileInfo>
#include <QDBusMessage>
#include <QProcess>
#include <QProcessEnvironment>
#include <polkitqt1-authority.h>
#include <polkitqt1-subject.h>

namespace {
constexpr auto ServiceError = "org.meo.Repair1.Error";
constexpr auto AuthorizationError = "org.meo.Repair1.NotAuthorized";

QString boundedProcessMessage(QProcess &process)
{
    return QString::fromUtf8(process.readAll()).simplified().left(800);
}
}

PrivilegedRepairService::PrivilegedRepairService(QObject *parent)
    : QObject(parent)
{
}

bool PrivilegedRepairService::authorizeCaller(const QString &polkitActionId)
{
    if (!calledFromDBus()) {
        sendErrorReply(AuthorizationError, QStringLiteral("A system D-Bus caller is required."));
        return false;
    }
    const QString caller = message().service();
    if (!caller.startsWith(QLatin1Char(':'))) {
        sendErrorReply(AuthorizationError, QStringLiteral("The D-Bus caller identity is invalid."));
        return false;
    }
    const PolkitQt1::SystemBusNameSubject subject(caller);
    const auto result = PolkitQt1::Authority::instance()->checkAuthorizationSync(
        polkitActionId, subject, PolkitQt1::Authority::AllowUserInteraction);
    if (result != PolkitQt1::Authority::Yes) {
        sendErrorReply(AuthorizationError,
                       QStringLiteral("Polkit did not authorize this exact repair action."));
        return false;
    }
    return true;
}

QVariantMap PrivilegedRepairService::runAuthorized(const QString &polkitActionId,
                                                   const QString &fixedProgram,
                                                   int timeoutMilliseconds)
{
    if (!authorizeCaller(polkitActionId))
        return {};
    const QFileInfo program(fixedProgram);
    if (!program.isAbsolute() || !program.exists() || !program.isFile()
        || !program.isExecutable() || program.isSymLink()) {
        sendErrorReply(ServiceError, QStringLiteral("The fixed repair implementation is unavailable."));
        return {};
    }

    QProcess process;
    process.setProcessChannelMode(QProcess::MergedChannels);
    QProcessEnvironment environment;
    environment.insert(QStringLiteral("PATH"), QStringLiteral("/usr/bin"));
    environment.insert(QStringLiteral("LANG"), QStringLiteral("C.UTF-8"));
    environment.insert(QStringLiteral("MEOARCH_REPAIR_SCOPE"), QStringLiteral("system"));
    environment.insert(QStringLiteral("MEOARCH_TARGET_ROOT"), QStringLiteral("/mnt"));
    process.setProcessEnvironment(environment);
    process.start(fixedProgram, {});
    if (!process.waitForStarted(3000)) {
        sendErrorReply(ServiceError, QStringLiteral("The fixed repair implementation could not start."));
        return {};
    }
    if (!process.waitForFinished(timeoutMilliseconds)) {
        process.kill();
        process.waitForFinished(2000);
        sendErrorReply(ServiceError, QStringLiteral("The fixed repair implementation timed out."));
        return {};
    }
    const QString detail = boundedProcessMessage(process);
    const bool success = process.exitStatus() == QProcess::NormalExit
        && process.exitCode() == 0;
    return QVariantMap{
        {QStringLiteral("success"), success},
        {QStringLiteral("resultCode"), process.exitCode()},
        {QStringLiteral("summary"), detail.isEmpty()
             ? (success ? QStringLiteral("The fixed action and post-check completed.")
                        : QStringLiteral("The fixed action failed without additional output."))
             : detail}
    };
}

QVariantMap PrivilegedRepairService::ReloadSystemdManager()
{
    return runAuthorized(QStringLiteral("org.meo.repair.reload-systemd-manager"),
                         QStringLiteral("/usr/lib/meoarch-repair/actions/reload-systemd-manager.sh"),
                         30000);
}

QVariantMap PrivilegedRepairService::RestartNetworkManager()
{
    return runAuthorized(QStringLiteral("org.meo.repair.restart-network-manager"),
                         QStringLiteral("/usr/lib/meoarch-repair/actions/restart-network-manager.sh"),
                         60000);
}

QVariantMap PrivilegedRepairService::RebuildInitramfs()
{
    return runAuthorized(QStringLiteral("org.meo.repair.rebuild-initramfs"),
                         QStringLiteral("/usr/lib/meoarch-repair/actions/rebuild-initramfs.sh"),
                         5 * 60 * 1000);
}

QVariantMap PrivilegedRepairService::RefreshPacmanKeyring()
{
    return runAuthorized(QStringLiteral("org.meo.repair.refresh-pacman-keyring"),
                         QStringLiteral("/usr/lib/meoarch-repair/actions/refresh-pacman-keyring.sh"),
                         2 * 60 * 1000);
}
