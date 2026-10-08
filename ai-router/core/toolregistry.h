#pragma once

#include <QJsonObject>
#include <QString>
#include <QStringList>
#include <QVector>

namespace MeoAi {

struct ToolDescriptor final
{
    QString name;
    QString capabilityId;
    QString title;
    QString description;
    QStringList keywords;
    QJsonObject inputSchema;
};

class ToolRegistry final
{
public:
    static const QVector<ToolDescriptor> &all();
    static const ToolDescriptor *find(const QString &name);
    static QVector<const ToolDescriptor *> search(const QString &query, int limit = 8);
};

} // namespace MeoAi
