#include "terminalworkspaceexecutor.h"
#include "terminalpolicy.h"

#include <QElapsedTimer>

#include <QDir>
#include <QFileInfo>
#include <QJsonObject>
#include <QProcess>
#include <QStandardPaths>

namespace MeoAi {
namespace {

constexpr qsizetype kMaxCapturedBytes = 64 * 1024;

QString boundedText(QByteArray data)
{
    if (data.size() > kMaxCapturedBytes) {
        data = data.left(kMaxCapturedBytes);
        data.append("\n[output truncated by Meo AI Router]\n");
    }
    return QString::fromUtf8(data);
}

CapabilityResult rejected(const QString &code, const QString &message)
{
    return {false, QStringLiteral("rejected"), code, message, {}, {}, false};
}

CapabilityResult unavailable(const QString &code, const QString &message)
{
    return {false, QStringLiteral("unavailable"), code, message, {}, {}, false};
}

} // namespace

CapabilityResult TerminalWorkspaceExecutor::execute(const Capability &,
                                                     const CapabilityRequest &request)
{
    const QString configuredRoot = qEnvironmentVariable("MEO_AI_WORKSPACE_ROOT").trimmed();
    if (configuredRoot.isEmpty()) {
        return unavailable(QStringLiteral("terminal_workspace_not_configured"),
                           QStringLiteral("No LLM terminal workspace has been granted."));
    }

    const QFileInfo rootInfo(configuredRoot);
    const QString root = rootInfo.canonicalFilePath();
    if (root.isEmpty() || !rootInfo.isDir()) {
        return unavailable(QStringLiteral("terminal_workspace_invalid"),
                           QStringLiteral("The granted terminal workspace is unavailable."));
    }

    const QString requestedCwd = request.input.value(QStringLiteral("cwd")).toString();
    const QString relativeCwd = requestedCwd.trimmed().isEmpty()
        ? QStringLiteral(".")
        : QDir::cleanPath(requestedCwd);
    if (QDir::isAbsolutePath(relativeCwd)
        || relativeCwd == QStringLiteral("..")
        || relativeCwd.startsWith(QStringLiteral("../"))) {
        return rejected(QStringLiteral("terminal_cwd_outside_workspace"),
                        QStringLiteral("Terminal cwd must stay inside the granted workspace."));
    }

    const QFileInfo cwdInfo(QDir(root).filePath(relativeCwd));
    const QString hostCwd = cwdInfo.canonicalFilePath();
    const QString rootPrefix = root.endsWith(QDir::separator()) ? root : root + QDir::separator();
    if (hostCwd.isEmpty() || !cwdInfo.isDir()
        || (hostCwd != root && !hostCwd.startsWith(rootPrefix))) {
        return rejected(QStringLiteral("terminal_cwd_outside_workspace"),
                        QStringLiteral("Terminal cwd must resolve to an existing directory inside the workspace."));
    }

    const QString bwrap = QStandardPaths::findExecutable(QStringLiteral("bwrap"));
    if (bwrap.isEmpty()) {
        return unavailable(QStringLiteral("terminal_sandbox_unavailable"),
                           QStringLiteral("bubblewrap is required for LLM terminal isolation."));
    }

    const QString bash = QStringLiteral("/usr/bin/bash");
    if (!QFileInfo::exists(bash)) {
        return unavailable(QStringLiteral("terminal_shell_unavailable"),
                           QStringLiteral("/usr/bin/bash is required for the LLM terminal."));
    }

    QString sandboxCwd = QStringLiteral("/workspace");
    if (hostCwd != root)
        sandboxCwd += QStringLiteral("/") + QDir(root).relativeFilePath(hostCwd);

    QStringList arguments{
        QStringLiteral("--die-with-parent"),
        QStringLiteral("--new-session"),
        QStringLiteral("--unshare-user"),
        QStringLiteral("--unshare-pid"),
        QStringLiteral("--unshare-ipc"),
        QStringLiteral("--unshare-uts"),
        QStringLiteral("--unshare-cgroup"),
        QStringLiteral("--cap-drop"), QStringLiteral("ALL"),
        QStringLiteral("--ro-bind"), QStringLiteral("/usr"), QStringLiteral("/usr"),
        QStringLiteral("--ro-bind"), QStringLiteral("/etc"), QStringLiteral("/etc"),
        QStringLiteral("--dev"), QStringLiteral("/dev"),
        QStringLiteral("--proc"), QStringLiteral("/proc"),
        QStringLiteral("--tmpfs"), QStringLiteral("/tmp"),
        QStringLiteral("--bind"), root, QStringLiteral("/workspace"),
        QStringLiteral("--chdir"), sandboxCwd,
        QStringLiteral("--clearenv"),
        QStringLiteral("--setenv"), QStringLiteral("HOME"), QStringLiteral("/workspace"),
        QStringLiteral("--setenv"), QStringLiteral("PATH"), QStringLiteral("/usr/bin"),
        QStringLiteral("--setenv"), QStringLiteral("LANG"), QStringLiteral("C.UTF-8"),
        QStringLiteral("--setenv"), QStringLiteral("MEO_AI_WORKSPACE"), QStringLiteral("/workspace"),
    };

    const bool networkAllowed = request.grantedPermissions.contains(QStringLiteral("terminal.network"));
    if (!networkAllowed)
        arguments.append(QStringLiteral("--unshare-net"));

    arguments.append(QStringLiteral("--"));
    arguments.append(bash);
    arguments.append(QStringLiteral("--noprofile"));
    arguments.append(QStringLiteral("--norc"));
    arguments.append(QStringLiteral("-c"));
    arguments.append(request.input.value(QStringLiteral("command")).toString());

    const int timeoutSeconds = request.input.value(QStringLiteral("timeoutSeconds")).toInt(30);

    QProcess process;
    process.setProcessChannelMode(QProcess::SeparateChannels);
    process.start(bwrap, arguments, QIODevice::ReadOnly);
    if (!process.waitForStarted(3000)) {
        return unavailable(QStringLiteral("terminal_sandbox_start_failed"), process.errorString());
    }

    bool timedOut = false;
    bool outputTruncated = false;
    QByteArray stdoutBuffer;
    QByteArray stderrBuffer;
    auto drain = [&] {
        auto append = [&](QByteArray &buffer, const QByteArray &chunk) {
            const qsizetype room = kMaxCapturedBytes - buffer.size();
            buffer.append(chunk.left(room));
            if (chunk.size() > room)
                outputTruncated = true;
        };
        append(stdoutBuffer, process.readAllStandardOutput());
        append(stderrBuffer, process.readAllStandardError());
    };
    QElapsedTimer timer;
    timer.start();
    while (process.state() != QProcess::NotRunning) {
        const qint64 remaining = timeoutSeconds * 1000 - timer.elapsed();
        if (remaining <= 0) {
            timedOut = true;
            process.kill();
            process.waitForFinished(1000);
            break;
        }
        process.waitForReadyRead(static_cast<int>(qMin<qint64>(remaining, 200)));
        drain();
    }
    drain();
    const auto risk = TerminalPolicy::classify(request.input.value(QStringLiteral("command")).toString());

    const int exitCode = process.exitStatus() == QProcess::NormalExit ? process.exitCode() : -1;
    QJsonObject data{
        {QStringLiteral("exitCode"), exitCode},
        {QStringLiteral("timedOut"), timedOut},
        {QStringLiteral("outputTruncated"), outputTruncated},
        {QStringLiteral("risk"), TerminalPolicy::riskName(risk.risk)},
        {QStringLiteral("riskReason"), risk.reason},
        {QStringLiteral("stdout"), boundedText(stdoutBuffer)},
        {QStringLiteral("stderr"), boundedText(stderrBuffer)},
        {QStringLiteral("cwd"), sandboxCwd},
        {QStringLiteral("networkAllowed"), networkAllowed},
    };

    if (timedOut) {
        return {false, QStringLiteral("failed"), QStringLiteral("terminal_timeout"),
                QStringLiteral("The terminal command exceeded its time limit."), {}, data, false};
    }
    if (exitCode != 0) {
        return {false, QStringLiteral("failed"), QStringLiteral("terminal_command_failed"),
                QStringLiteral("The terminal command exited with a non-zero status."), {}, data, false};
    }

    return {true, QStringLiteral("ok"), QStringLiteral("terminal_completed"), {}, {}, data, false};
}

} // namespace MeoAi
