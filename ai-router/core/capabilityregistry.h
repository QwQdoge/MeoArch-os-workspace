#pragma once

#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QStringList>
#include <QVector>

namespace MeoAi {

struct Capability final
{
    QString id;
    QString owner;
    QString description;
    QString effect;
    QString privilege;
    QString confirmation;
    QString executorId;
    QJsonObject inputSchema;
    QJsonObject fixedArguments;
    QStringList requiredPermissions;
    QStringList verifyCapabilities;
    bool executable = false;
    bool mcpExposed = false;
};

class CapabilityRegistry final
{
public:
    CapabilityRegistry();

    const QVector<Capability> &all() const { return m_capabilities; }
    const Capability *find(const QString &id) const;
    bool registerCapability(const Capability &capability, QString *error = nullptr);

    static QString policyVersion();
    static bool validateDescriptor(const Capability &capability, QString *error = nullptr);

private:
    QVector<Capability> m_capabilities;
};

} // namespace MeoAi
