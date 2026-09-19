#pragma once

#include <QJsonObject>
#include <QString>

namespace MeoRepair {

class SessionJournal final
{
public:
    SessionJournal();

    QString path() const { return m_path; }
    bool append(const QJsonObject &event, QString *error = nullptr) const;
    QJsonObject lastEvent() const;

private:
    QString m_path;
};

} // namespace MeoRepair
