#include "mcpgatewayadapter.h"
#include "systemairouter.h"

#include <QCommandLineParser>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QTextStream>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("meo-ai-router"));

    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addOption({QStringLiteral("list"), QStringLiteral("List registered capabilities as JSON.")});
    parser.addOption({QStringLiteral("list-mcp"), QStringLiteral("List capabilities exported by the MCP adapter as JSON.")});
    parser.addOption({QStringLiteral("invoke"), QStringLiteral("Invoke a registered no-argument capability."), QStringLiteral("capability")});
    parser.process(app);

    MeoAi::SystemAiRouter router;
    QJsonDocument document;

    if (parser.isSet(QStringLiteral("list"))) {
        QJsonArray capabilities;
        for (const MeoAi::Capability &capability : router.registry().all()) {
            capabilities.append(QJsonObject{
                {QStringLiteral("id"), capability.id},
                {QStringLiteral("owner"), capability.owner},
                {QStringLiteral("effect"), capability.effect},
                {QStringLiteral("executable"), capability.executable},
                {QStringLiteral("mcpExposed"), capability.mcpExposed},
            });
        }
        document = QJsonDocument(capabilities);
    } else if (parser.isSet(QStringLiteral("list-mcp"))) {
        MeoAi::McpGatewayAdapter gateway(&router.registry());
        document = QJsonDocument(gateway.toolCatalog());
    } else if (parser.isSet(QStringLiteral("invoke"))) {
        MeoAi::CapabilityRequest request;
        request.capabilityId = parser.value(QStringLiteral("invoke"));
        request.callerId = QStringLiteral("meo-ai-router-cli");
        request.origin = QStringLiteral("native");
        document = QJsonDocument(router.invoke(request).toJson());
    } else {
        parser.showHelp(0);
    }

    QTextStream(stdout) << document.toJson(QJsonDocument::Indented);
    return 0;
}
