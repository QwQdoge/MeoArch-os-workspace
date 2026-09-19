#pragma once

#include <QDBusContext>
#include <QObject>
#include <QVariantMap>

class PrivilegedRepairService final : public QObject, protected QDBusContext
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.meo.Repair1")

public:
    explicit PrivilegedRepairService(QObject *parent = nullptr);

public slots:
    QVariantMap ReloadSystemdManager();
    QVariantMap RestartNetworkManager();
    QVariantMap RebuildInitramfs();
    QVariantMap RefreshPacmanKeyring();

private:
    QVariantMap runAuthorized(const QString &polkitActionId,
                              const QString &fixedProgram,
                              int timeoutMilliseconds);
    bool authorizeCaller(const QString &polkitActionId);
};
