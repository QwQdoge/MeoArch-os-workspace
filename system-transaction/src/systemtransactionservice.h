#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>

class SystemTransactionService final : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.meo.SystemTransaction1")

public:
    explicit SystemTransactionService(QObject *parent = nullptr);

public Q_SLOTS:
    QVariantMap Inspect(const QString &kind, const QVariantMap &request) const;
};
