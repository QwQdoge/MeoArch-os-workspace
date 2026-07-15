#include "installercontroller.h"

#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextStream>
#include <memory>

int main(int argc, char *argv[])
{
    bool dumpRequested = false;
    for (int index = 1; index < argc; ++index)
        dumpRequested = dumpRequested || QString::fromLocal8Bit(argv[index]) == QStringLiteral("--dump-catalog-counts");
    std::unique_ptr<QCoreApplication> application;
    if (dumpRequested)
        application = std::make_unique<QCoreApplication>(argc, argv);
    else
        application = std::make_unique<QGuiApplication>(argc, argv);
    QCoreApplication &app = *application;
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArch"));
    QCoreApplication::setApplicationName(QStringLiteral("MeoArch Installer"));

    InstallerController controller(app.arguments());
    const int dumpIndex = app.arguments().indexOf(QStringLiteral("--dump-catalog-counts"));
    if (dumpIndex >= 0) {
        const QJsonObject counts{
            {QStringLiteral("uiLanguages"), controller.uiLanguages().size()},
            {QStringLiteral("systemLocales"), controller.systemLocales().size()},
            {QStringLiteral("countries"), controller.countries().size()},
            {QStringLiteral("timeZones"), controller.timeZones().size()},
            {QStringLiteral("keyboardLayouts"), controller.keyboardLayouts().size()}
        };
        const QByteArray payload = QJsonDocument(counts).toJson(QJsonDocument::Compact) + '\n';
        if (dumpIndex + 1 < app.arguments().size() && !app.arguments().at(dumpIndex + 1).startsWith(QStringLiteral("--"))) {
            QFile output(app.arguments().at(dumpIndex + 1));
            if (!output.open(QIODevice::WriteOnly | QIODevice::Truncate))
                return 2;
            output.write(payload);
        } else {
            QTextStream(stdout) << payload;
        }
        return 0;
    }
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("installerController"), &controller);

    QString qmlRoot = qEnvironmentVariable("MEOARCH_INSTALLER_QML_ROOT");
    if (qmlRoot.isEmpty()) {
        const QString installed = QStringLiteral("/usr/lib/meoarch-installer/qml");
        const QString development = QDir(QCoreApplication::applicationDirPath())
                                        .absoluteFilePath(QStringLiteral("../../installer/qml"));
        qmlRoot = QFileInfo::exists(installed + QStringLiteral("/Main.qml")) ? installed : development;
    }
    engine.addImportPath(qmlRoot);
    engine.addImportPath(QStringLiteral("/opt/meo-ui/qml"));
    engine.load(QUrl::fromLocalFile(QDir(qmlRoot).absoluteFilePath(QStringLiteral("Main.qml"))));
    if (engine.rootObjects().isEmpty())
        return 1;
    return app.exec();
}
