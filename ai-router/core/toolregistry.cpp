#include "toolregistry.h"
#include "capabilityregistry.h"

#include <QJsonArray>

namespace MeoAi {
const QVector<ToolDescriptor> &ToolRegistry::all()
{
    static const QVector<ToolDescriptor> tools = [] {
        QVector<ToolDescriptor> result;
        const CapabilityRegistry registry;
        for (const Capability &capability : registry.all()) {
            result.append({capability.id, capability.id, capability.id,
                           capability.description,
                           {capability.id, capability.owner, capability.effect},
                           capability.inputSchema});
        }
        return result;
    }();
    return tools;
}

const ToolDescriptor *ToolRegistry::find(const QString &name)
{
    for (const ToolDescriptor &tool : all()) {
        if (tool.name == name)
            return &tool;
    }
    return nullptr;
}

QVector<const ToolDescriptor *> ToolRegistry::search(const QString &query, int limit)
{
    QVector<const ToolDescriptor *> matches;
    if (limit <= 0)
        return matches;
    limit = qMin(limit, 32);

    const QStringList terms = query.toLower().split(QChar::Space, Qt::SkipEmptyParts);
    for (const ToolDescriptor &tool : all()) {
        QString haystack = tool.name + QChar::Space + tool.capabilityId + QChar::Space
            + tool.title + QChar::Space + tool.description + QChar::Space
            + tool.keywords.join(QChar::Space);
        haystack = haystack.toLower();

        bool matchesAll = true;
        for (const QString &term : terms) {
            if (!haystack.contains(term)) {
                matchesAll = false;
                break;
            }
        }
        if (!matchesAll)
            continue;
        matches.append(&tool);
        if (matches.size() >= limit)
            break;
    }
    return matches;
}

} // namespace MeoAi
