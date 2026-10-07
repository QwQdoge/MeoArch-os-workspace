#pragma once

#include <QString>
#include <QVariantMap>

class TransactionValidator final
{
public:
    static QVariantMap inspect(const QString &kind, const QVariantMap &request);

private:
    static QVariantMap error(const QString &code, const QString &message);
    static QVariantMap inspectConfiguration(const QVariantMap &request);
    static QVariantMap inspectLoginSessionEntry(const QVariantMap &request);
};
