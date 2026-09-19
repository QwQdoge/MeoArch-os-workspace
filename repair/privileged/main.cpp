#include "privilegedrepairservice.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QTextStream>

int main(int argc, char **argv)
{
    QCoreApplication application(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArch"));
    QCoreApplication::setApplicationName(QStringLiteral("RepairPrivilegedService"));

    QDBusConnection bus = QDBusConnection::systemBus();
    if (!bus.isConnected()
        || !bus.registerService(QStringLiteral("org.meo.Repair1"))) {
        QTextStream(stderr) << "Unable to own org.meo.Repair1 on the system bus.\n";
        return 1;
    }
    PrivilegedRepairService service;
    if (!bus.registerObject(QStringLiteral("/org/meo/Repair1"), &service,
                            QDBusConnection::ExportAllSlots)) {
        QTextStream(stderr) << "Unable to export the privileged repair object.\n";
        return 2;
    }
    return application.exec();
}
