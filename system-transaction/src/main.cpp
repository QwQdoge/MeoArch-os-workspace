#include "systemtransactionservice.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QTextStream>

int main(int argc, char **argv)
{
    QCoreApplication application(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArch"));
    QCoreApplication::setApplicationName(QStringLiteral("SystemTransactionService"));

    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected()) {
        QTextStream(stderr) << "Unable to connect to the system bus.\n";
        return 1;
    }
    if (!bus.registerService(QStringLiteral("org.meo.SystemTransaction1"))) {
        QTextStream(stderr) << "Unable to own org.meo.SystemTransaction1 on the system bus.\n";
        return 2;
    }

    SystemTransactionService service;
    if (!bus.registerObject(QStringLiteral("/org/meo/SystemTransaction1"), &service,
                            QDBusConnection::ExportAllSlots)) {
        QTextStream(stderr) << "Unable to export /org/meo/SystemTransaction1.\n";
        return 3;
    }

    return application.exec();
}
