#include "mcpgatewayadapter.h"

namespace MeoAi {

QString McpGatewayAdapter::toolNameForCapability(const QString &capabilityId)
{
    QString name = QStringLiteral("meo_") + capabilityId;
    name.replace(QStringLiteral("."), QStringLiteral("__"));
    name.replace(QStringLiteral("-"), QStringLiteral("_dash_"));
    return name;
}

QJsonArray McpGatewayAdapter::toolCatalog() const
{
    QJsonArray tools;
    if (!m_registry)
        return tools;

    for (const Capability &capability : m_registry->all()) {
        if (!capability.executable || !capability.mcpExposed)
            continue;
        tools.append(QJsonObject{
            {QStringLiteral("name"), toolNameForCapability(capability.id)},
            {QStringLiteral("description"), capability.description},
            {QStringLiteral("inputSchema"), capability.inputSchema},
            {QStringLiteral("annotations"), QJsonObject{
                 {QStringLiteral("capabilityId"), capability.id},
                 {QStringLiteral("owner"), capability.owner},
                 {QStringLiteral("effect"), capability.effect},
             }},
        });
    }
    return tools;
}

bool McpGatewayAdapter::requestForTool(const QString &toolName,
                                       const QJsonObject &arguments,
                                       const QString &callerId,
                                       CapabilityRequest *request,
                                       QString *error) const
{
    if (!m_registry || !request) {
        if (error)
            *error = QStringLiteral("MCP gateway is not initialized");
        return false;
    }

    for (const Capability &capability : m_registry->all()) {
        if (!capability.executable || !capability.mcpExposed)
            continue;
        if (toolNameForCapability(capability.id) != toolName)
            continue;

        request->capabilityId = capability.id;
        request->input = arguments;
        request->callerId = callerId;
        request->origin = QStringLiteral("mcp");
        request->confirmed = false;
        return true;
    }

    if (error)
        *error = QStringLiteral("MCP tool is not mapped to an approved capability");
    return false;
}

} // namespace MeoAi
