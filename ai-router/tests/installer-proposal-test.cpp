#include "installerproposalexecutor.h"
#include "mcpgatewayadapter.h"
#include "systemairouter.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QTemporaryDir>
#include <QTextStream>

namespace {
int fail(int code, const char *message)
{
    QTextStream(stderr) << "FAIL(" << code << "): " << message << '\n';
    return code;
}
}

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QTemporaryDir dir;
    qputenv("MEO_INSTALLER_PROPOSAL_DIR", dir.path().toUtf8());
    const QString logFile = dir.filePath(QStringLiteral("install.log"));
    qputenv("MEO_INSTALLER_LOG", logFile.toUtf8());

    MeoAi::SystemAiRouter router;
    MeoAi::CapabilityRequest request;
    request.capabilityId = QStringLiteral("installer.proposal.submit");
    request.callerId = QStringLiteral("meo-ai");

    // A well-formed proposal is written and nothing else happens.
    request.input = {{QStringLiteral("systemLocale"), QStringLiteral("zh_CN.UTF-8")},
                     {QStringLiteral("timezone"), QStringLiteral("Asia/Shanghai")},
                     {QStringLiteral("filesystem"), QStringLiteral("ext4")},
                     {QStringLiteral("applications"), QStringLiteral("firefox, vlc")},
                     {QStringLiteral("separateHome"), true}};
    MeoAi::CapabilityResult result = router.invoke(request);
    if (!result.ok)
        return fail(1, "valid proposal was rejected");
    QFile written(MeoAi::InstallerProposalExecutor::proposalPath());
    if (!written.open(QIODevice::ReadOnly))
        return fail(2, "proposal file was not written");
    const QJsonObject document = QJsonDocument::fromJson(written.readAll()).object();
    const QJsonObject selections = document.value(QStringLiteral("selections")).toObject();
    if (selections.value(QStringLiteral("disk")).toObject().value(QStringLiteral("filesystem")).toString() != QStringLiteral("ext4")
        || selections.value(QStringLiteral("software")).toObject().value(QStringLiteral("applications")).toArray().size() != 2)
        return fail(3, "proposal was not normalized into sections");

    // Fields that would touch disks or accounts are unknown to the schema.
    const QStringList forbidden{QStringLiteral("targetDisk"), QStringLiteral("password"),
                                QStringLiteral("username"), QStringLiteral("mode")};
    for (const QString &key : forbidden) {
        request.input = {{key, QStringLiteral("x")}};
        result = router.invoke(request);
        if (result.ok)
            return fail(4, "a disk/account field was accepted");
    }

    // Injection-shaped values are rejected by the executor even if the schema passes them.
    const QList<QPair<QString, QJsonValue>> bad{
        {QStringLiteral("timezone"), QStringLiteral("../../etc/passwd")},
        {QStringLiteral("applications"), QStringLiteral("firefox;rm -rf /")},
        {QStringLiteral("systemLocale"), QStringLiteral("en_US")},
        {QStringLiteral("keyboardLayout"), QStringLiteral("us layout")},
    };
    for (const auto &entry : bad) {
        request.input = {{entry.first, entry.second}};
        result = router.invoke(request);
        if (result.ok)
            return fail(5, "an injection-shaped value was accepted");
    }
    request.input = {{QStringLiteral("filesystem"), QStringLiteral("xfs")}};
    if (router.invoke(request).ok)
        return fail(6, "an unsupported filesystem was accepted");
    request.input = {};
    if (router.invoke(request).ok)
        return fail(7, "an empty proposal was accepted");

    // Log reading is bounded to the requested tail.
    QFile log(logFile);
    log.open(QIODevice::WriteOnly);
    for (int i = 0; i < 100; ++i)
        log.write(QByteArray("line ") + QByteArray::number(i) + '\n');
    log.close();
    request.capabilityId = QStringLiteral("installer.log.read");
    request.input = {{QStringLiteral("lines"), 5}};
    result = router.invoke(request);
    const QJsonArray lines = result.data.value(QStringLiteral("lines")).toArray();
    if (!result.ok || lines.size() != 5 || lines.last().toString() != QStringLiteral("line 99"))
        return fail(8, "log tail is wrong");

    // Both are exported through MCP, the terminal still is not.
    MeoAi::McpGatewayAdapter gateway(&router.registry());
    bool proposeExposed = false;
    for (const QJsonValue &tool : gateway.toolCatalog()) {
        const QString name = tool.toObject().value(QStringLiteral("name")).toString();
        if (name.contains(QStringLiteral("terminal")))
            return fail(9, "terminal leaked into MCP");
        if (name.contains(QStringLiteral("proposal")))
            proposeExposed = true;
    }
    if (!proposeExposed)
        return fail(10, "installer proposal is not exported through MCP");

    QTextStream(stdout) << "PASS: installer proposals are allow-listed, bounded and propose-only\n";
    return 0;
}
