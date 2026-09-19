#include "sessionjournal.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QStandardPaths>

namespace MeoRepair {

SessionJournal::SessionJournal()
{
    QString root = QStandardPaths::writableLocation(QStandardPaths::RuntimeLocation);
    if (root.isEmpty())
        root = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir directory(root);
    if (directory.mkpath(QStringLiteral("meoarch-repair")))
        m_path = directory.absoluteFilePath(QStringLiteral("meoarch-repair/session-journal.jsonl"));
}

bool SessionJournal::append(const QJsonObject &event, QString *error) const
{
    if (m_path.isEmpty()) {
        if (error)
            *error = QStringLiteral("No private runtime directory is available.");
        return false;
    }
    QFile file(m_path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        if (error)
            *error = file.errorString();
        return false;
    }
    file.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    const QByteArray line = QJsonDocument(event).toJson(QJsonDocument::Compact) + '\n';
    if (file.write(line) != line.size() || !file.flush()) {
        if (error)
            *error = file.errorString();
        return false;
    }
    return true;
}

QJsonObject SessionJournal::lastEvent() const
{
    QFile file(m_path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    QJsonObject last;
    while (!file.atEnd()) {
        const QJsonDocument document = QJsonDocument::fromJson(file.readLine().trimmed());
        if (document.isObject())
            last = document.object();
    }
    return last;
}

} // namespace MeoRepair
