#pragma once

#include "systemairouter.h"

#include <QJsonArray>

namespace MeoAi {

class McpGatewayAdapter final
{
public:
    explicit McpGatewayAdapter(const CapabilityRegistry *registry)
        : m_registry(registry) {}

    QJsonArray toolCatalog() const;
    bool requestForTool(const QString &toolName,
                        const QJsonObject &arguments,
                        const QString &callerId,
                        CapabilityRequest *request,
                        QString *error = nullptr) const;

    static QString toolNameForCapability(const QString &capabilityId);

private:
    const CapabilityRegistry *m_registry = nullptr;
};

} // namespace MeoAi
