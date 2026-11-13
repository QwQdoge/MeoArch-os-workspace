#include "installerproposalexecutor.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QRegularExpression>
#include <QSaveFile>
#include <QSet>

namespace MeoAi {
namespace {

CapabilityResult failure(const Capability &capability, const QString &status,
                         const QString &code, const QString &message)
{
    return {false, status, code, message, capability.id, {}, false};
}

QString runtimeDirectory()
{
    const QString override = qEnvironmentVariable("MEO_INSTALLER_PROPOSAL_DIR");
    if (!override.isEmpty())
        return override;
    const QString runtime = qEnvironmentVariable("XDG_RUNTIME_DIR");
    return runtime.isEmpty() ? QString() : QDir(runtime).absoluteFilePath(QStringLiteral("meo-installer"));
}

QString logPath()
{
    const QString override = qEnvironmentVariable("MEO_INSTALLER_LOG");
    return override.isEmpty() ? QStringLiteral("/tmp/meoarch-installer/logs/install.log") : override;
}

bool matches(const QString &pattern, const QString &value)
{
    return QRegularExpression(QStringLiteral("^(?:%1)$").arg(pattern)).match(value).hasMatch();
}

} // namespace

bool InstallerProposalExecutor::liveEnvironment()
{
    return QDir(QStringLiteral("/run/archiso")).exists()
        || !qEnvironmentVariable("MEO_INSTALLER_PROPOSAL_DIR").isEmpty();
}

QString InstallerProposalExecutor::proposalPath()
{
    const QString dir = runtimeDirectory();
    return dir.isEmpty() ? QString() : QDir(dir).absoluteFilePath(QStringLiteral("ai-proposal.json"));
}

QJsonObject InstallerProposalExecutor::normalizeProposal(const QJsonObject &input, QString *error)
{
    auto fail = [error](const QString &message) {
        if (error)
            *error = message;
        return QJsonObject();
    };

    QJsonObject locale;
    QJsonObject software;
    QJsonObject disk;
    QJsonObject privacy;

    for (auto it = input.constBegin(); it != input.constEnd(); ++it) {
        const QString key = it.key();
        const QJsonValue value = it.value();
        if (key == QStringLiteral("rationale"))
            continue;
        if (key == QStringLiteral("systemLocale")) {
            if (!matches(QStringLiteral("[a-z]{2,3}_[A-Z]{2}\\.UTF-8"), value.toString()))
                return fail(QStringLiteral("systemLocale must look like en_US.UTF-8"));
            locale.insert(key, value.toString());
        } else if (key == QStringLiteral("timezone")) {
            if (!matches(QStringLiteral("[A-Za-z0-9_+\\-]+(?:/[A-Za-z0-9_+\\-]+){0,2}"), value.toString()))
                return fail(QStringLiteral("timezone must be an IANA zone id"));
            locale.insert(key, value.toString());
        } else if (key == QStringLiteral("keyboardLayout")) {
            if (!matches(QStringLiteral("[a-z0-9_\\-]{1,32}"), value.toString()))
                return fail(QStringLiteral("keyboardLayout is invalid"));
            locale.insert(key, value.toString());
        } else if (key == QStringLiteral("profile") || key == QStringLiteral("channel")) {
            static const QSet<QString> profiles{QStringLiteral("recommended"), QStringLiteral("minimal")};
            static const QSet<QString> channels{QStringLiteral("stable"), QStringLiteral("beta")};
            const QString text = value.toString();
            if (!(key == QStringLiteral("profile") ? profiles : channels).contains(text))
                return fail(key + QStringLiteral(" is not an allowed value"));
            software.insert(key, text);
        } else if (key == QStringLiteral("applications")) {
            // Comma-separated catalog ids; the installer resolves them against
            // its own catalog and rejects anything unknown.
            QJsonArray ids;
            const QStringList parts = value.toString().split(QLatin1Char(','), Qt::SkipEmptyParts);
            if (parts.size() > 40)
                return fail(QStringLiteral("too many applications"));
            for (const QString &part : parts) {
                const QString id = part.trimmed();
                if (!matches(QStringLiteral("[a-z0-9][a-z0-9._+\\-]{0,63}"), id))
                    return fail(QStringLiteral("application id is invalid"));
                ids.append(id);
            }
            software.insert(key, ids);
        } else if (key == QStringLiteral("filesystem")) {
            if (value.toString() != QStringLiteral("btrfs") && value.toString() != QStringLiteral("ext4"))
                return fail(QStringLiteral("filesystem must be btrfs or ext4"));
            disk.insert(key, value.toString());
        } else if (key == QStringLiteral("swap")) {
            static const QSet<QString> modes{QStringLiteral("zram"), QStringLiteral("file"), QStringLiteral("none")};
            if (!modes.contains(value.toString()))
                return fail(QStringLiteral("swap mode is not allowed"));
            disk.insert(key, value.toString());
        } else if (key == QStringLiteral("separateHome")) {
            if (!value.isBool())
                return fail(QStringLiteral("separateHome must be boolean"));
            disk.insert(key, value.toBool());
        } else if (key == QStringLiteral("firewall")) {
            if (!value.isBool())
                return fail(QStringLiteral("firewall must be boolean"));
            privacy.insert(key, value.toBool());
        } else {
            // Disk targets, erase mode, accounts and passwords are never
            // accepted from a proposal.
            return fail(QStringLiteral("field is not proposable: ") + key);
        }
    }

    QJsonObject out;
    if (!locale.isEmpty()) out.insert(QStringLiteral("locale"), locale);
    if (!software.isEmpty()) out.insert(QStringLiteral("software"), software);
    if (!disk.isEmpty()) out.insert(QStringLiteral("disk"), disk);
    if (!privacy.isEmpty()) out.insert(QStringLiteral("privacy"), privacy);
    if (out.isEmpty())
        return fail(QStringLiteral("proposal contains no changes"));
    return out;
}

CapabilityResult InstallerProposalExecutor::execute(const Capability &capability,
                                                    const CapabilityRequest &request)
{
    if (!liveEnvironment()) {
        return failure(capability, QStringLiteral("unavailable"), QStringLiteral("installer_unavailable"),
                       QStringLiteral("The installer capabilities are only available in the MeoArch Live environment."));
    }

    if (capability.id == QStringLiteral("installer.log.read")) {
        QFile file(logPath());
        if (!file.open(QIODevice::ReadOnly))
            return failure(capability, QStringLiteral("unavailable"), QStringLiteral("log_unavailable"),
                           QStringLiteral("No installer log exists yet."));
        const int wanted = request.input.contains(QStringLiteral("lines"))
            ? request.input.value(QStringLiteral("lines")).toInt() : 60;
        // Read only the tail; the log can grow large during package installs.
        const qint64 window = 64 * 1024;
        file.seek(qMax<qint64>(0, file.size() - window));
        QStringList lines = QString::fromUtf8(file.readAll()).split(QLatin1Char('\n'));
        if (file.size() > window && !lines.isEmpty())
            lines.removeFirst();
        while (!lines.isEmpty() && lines.last().isEmpty())
            lines.removeLast();
        lines = lines.mid(qMax(0, lines.size() - wanted));
        QJsonArray out;
        for (const QString &line : std::as_const(lines))
            out.append(line.left(400));
        return {true, QStringLiteral("ok"), QStringLiteral("read"), QString(), capability.id,
                {{QStringLiteral("lines"), out}}, false};
    }

    if (capability.id != QStringLiteral("installer.proposal.submit"))
        return failure(capability, QStringLiteral("failed"), QStringLiteral("unknown_capability"),
                       QStringLiteral("The installer executor does not handle this capability."));

    QString error;
    const QJsonObject selections = normalizeProposal(request.input, &error);
    if (selections.isEmpty())
        return failure(capability, QStringLiteral("rejected"), QStringLiteral("proposal_invalid"), error);

    const QString path = proposalPath();
    if (path.isEmpty())
        return failure(capability, QStringLiteral("unavailable"), QStringLiteral("no_runtime_dir"),
                       QStringLiteral("No per-user runtime directory is available for the proposal."));
    QDir().mkpath(QFileInfo(path).absolutePath());
    QFile::setPermissions(QFileInfo(path).absolutePath(),
                          QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ExeOwner);

    const QJsonObject document{
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("createdAt"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate)},
        {QStringLiteral("rationale"), request.input.value(QStringLiteral("rationale")).toString().left(500)},
        {QStringLiteral("selections"), selections},
    };
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly))
        return failure(capability, QStringLiteral("failed"), QStringLiteral("write_failed"),
                       QStringLiteral("The proposal could not be written."));
    file.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    file.write(QJsonDocument(document).toJson(QJsonDocument::Compact));
    if (!file.commit())
        return failure(capability, QStringLiteral("failed"), QStringLiteral("write_failed"),
                       QStringLiteral("The proposal could not be saved."));

    return {true, QStringLiteral("ok"), QStringLiteral("proposed"),
            QStringLiteral("Proposal saved. Nothing was applied: the person must review and accept it in the installer."),
            capability.id, {{QStringLiteral("selections"), selections}}, false};
}

} // namespace MeoAi
