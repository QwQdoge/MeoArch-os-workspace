#include "installercontroller.h"

#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>
#include <QWindow>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextStream>
#include <QTranslator>
#include <algorithm>
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
    const QStringList arguments = app.arguments();
    if (arguments.contains(QStringLiteral("--production")) && arguments.contains(QStringLiteral("--preview"))) {
        QTextStream(stderr) << "--preview cannot be used with --production.\n";
        return 2;
    }

    InstallerController controller(arguments);
    for (const QString &argument : arguments) {
        if (argument.startsWith(QStringLiteral("--language=")))
            controller.setUiLanguage(argument.mid(11));
    }
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
    QTranslator translator;
    const auto loadLanguage = [&app, &engine, &translator](const QString &language) {
        app.removeTranslator(&translator);
        if (language != QStringLiteral("zh_CN")) {
            engine.retranslate();
            return;
        }
        QStringList paths;
        const QString configured = qEnvironmentVariable("MEOARCH_INSTALLER_TRANSLATIONS");
        if (!configured.isEmpty())
            paths.append(configured);
        paths.append(QStringLiteral("/opt/meoarch-installer/translations"));
#ifdef MEOARCH_TRANSLATIONS_BUILD_DIR
        paths.append(QString::fromUtf8(MEOARCH_TRANSLATIONS_BUILD_DIR));
#endif
        for (const QString &path : paths) {
            if (translator.load(QStringLiteral("meoarch_zh_CN"), path)) {
                app.installTranslator(&translator);
                break;
            }
        }
        engine.retranslate();
    };
    const QString configuredMeoUiPath = qEnvironmentVariable("MEO_UI_QML_IMPORT_PATH");
    if (!configuredMeoUiPath.isEmpty())
        engine.addImportPath(configuredMeoUiPath);
#ifdef MEOUI_QML_BUILD_IMPORT_PATH
    engine.addImportPath(QString::fromUtf8(MEOUI_QML_BUILD_IMPORT_PATH));
#endif
    engine.addImportPath(QStringLiteral("/usr/lib/qt6/qml"));
    int initialPage = 0;
    const bool visualPreview = app.arguments().contains(QStringLiteral("--preview"));
    for (const QString &argument : app.arguments()) {
        if (argument.startsWith(QStringLiteral("--page="))) {
            bool ok = false;
            const int requested = argument.mid(7).toInt(&ok);
            if (ok)
                initialPage = std::clamp(requested, 0, 10);
        }
    }
    engine.setInitialProperties({
        {QStringLiteral("installerController"), QVariant::fromValue(&controller)},
        {QStringLiteral("initialPage"), initialPage},
        {QStringLiteral("visualPreview"), visualPreview}
    });

    QString qmlRoot = qEnvironmentVariable("MEOARCH_INSTALLER_QML_ROOT");
    if (qmlRoot.isEmpty()) {
        const QString installed = QStringLiteral("/usr/lib/meoarch-installer/qml");
        const QString bundled = QDir(QCoreApplication::applicationDirPath())
                                    .absoluteFilePath(QStringLiteral("qml"));
#ifdef MEOARCH_QML_SOURCE_DIR
        const QString development = QString::fromUtf8(MEOARCH_QML_SOURCE_DIR);
#else
        const QString development = QDir(QCoreApplication::applicationDirPath())
                                        .absoluteFilePath(QStringLiteral("../../installer/qml"));
#endif
        if (QFileInfo::exists(installed + QStringLiteral("/Main.qml")))
            qmlRoot = installed;
        else if (QFileInfo::exists(bundled + QStringLiteral("/Main.qml")))
            qmlRoot = bundled;
        else
            qmlRoot = development;
    }
    engine.addImportPath(qmlRoot);
    engine.load(QUrl::fromLocalFile(QDir(qmlRoot).absoluteFilePath(QStringLiteral("Main.qml"))));
    if (engine.rootObjects().isEmpty())
        return 1;
    loadLanguage(controller.uiLanguage());
    QObject::connect(&controller, &InstallerController::uiLanguageChanged, &engine,
                     [&controller, &loadLanguage] { loadLanguage(controller.uiLanguage()); });

    // Keep visual-regression capture in the C++ host.  Let the source-page
    // fonts and window-level wallpaper settle before grabbing the first frame.
    QString screenshotPath;
    for (const QString &argument : app.arguments()) {
        if (argument.startsWith(QStringLiteral("--screenshot="))) {
            screenshotPath = argument.mid(13);
            break;
        }
    }
    if (!screenshotPath.isEmpty()) {
        if (auto *quickWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst())) {
            QTimer::singleShot(2200, quickWindow, [quickWindow, screenshotPath, &app]() {
                const QImage image = quickWindow->grabWindow();
                if (image.isNull() || !image.save(screenshotPath))
                    app.exit(2);
                else
                    app.quit();
            });
            QTimer::singleShot(8000, &app, [&app]() { app.exit(3); });
        }
    }
    return app.exec();
}
