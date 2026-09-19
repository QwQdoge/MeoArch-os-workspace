#pragma once

#include <QString>
#include <QStringList>
#include <QVector>

namespace MeoRepair {

struct Capability final
{
    QString id;
    QString category;
    QString effect;
    QString privilege;
    QString reversibility;
    QString exportability;
    QString rollbackCapabilityId;
    QStringList verifyToolIds;
    bool executable = false;
};

class CapabilityRegistry final
{
public:
    static QString policyVersion();
    static const QVector<Capability> &all();
    static const Capability *find(const QString &id);
};

} // namespace MeoRepair
