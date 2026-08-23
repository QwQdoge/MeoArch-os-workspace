#include "repaircontroller.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTextStream>
#include <QTimer>
#include <memory>

namespace {
QString optionValue(const QStringList &arguments, const QString &option,
                    const QString &fallback = {})
{
    const QString inlinePrefix = option + QLatin1Char('=');
    for (qsizetype index = 1; index < arguments.size(); ++index) {
        const QString &argument = arguments.at(index);
        if (argument.startsWith(inlinePrefix))
            return argument.mid(inlinePrefix.size());
        if (argument == option) {
            if (index + 1 < arguments.size()
                && !arguments.at(index + 1).startsWith(QLatin1Char('-'))) {
                return arguments.at(index + 1);
            }
            return {};
        }
    }
    return fallback;
}

void printUsage()
{
    QTextStream(stdout)
        << "MeoArch Quick Repair\n\n"
        << "  meoarch-repair                         Open the MeoUI graphical app\n"
        << "  meoarch-repair --cli --category all    Run fixed read-only checks\n"
        << "  meoarch-repair --cli --category=all    Equivalent inline form\n"
        << "  meoarch-repair --list-categories       Print category metadata as JSON\n"
        << "  --live                                  Use Live/target-aware behavior\n"
        << "  --kiosk                                 Request a full-screen window\n"
        << "  --preview-width N                       Width for a --preview screenshot\n";
}
}

int main(int argc, char *argv[])
{
    bool cliRequested = false;
    bool listRequested = false;
    bool liveRequested = false;
    for (int index = 1; index < argc; ++index) {
        const QString argument = QString::fromLocal8Bit(argv[index]);
        cliRequested = cliRequested || argument == QStringLiteral("--cli");
        listRequested = listRequested || argument == QStringLiteral("--list-categories");
        liveRequested = liveRequested || argument == QStringLiteral("--live");
    }
    if (liveRequested)
        qputenv("MEOARCH_REPAIR_SCOPE", "live");

    std::unique_ptr<QCoreApplication> application;
    if (cliRequested || listRequested)
        application = std::make_unique<QCoreApplication>(argc, argv);
    else
        application = std::make_unique<QGuiApplication>(argc, argv);
    QCoreApplication &app = *application;
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArch"));
    QCoreApplication::setApplicationName(QStringLiteral("MeoArch Repair"));
    const QStringList arguments = app.arguments();
    if (arguments.contains(QStringLiteral("--help"))
        || arguments.contains(QStringLiteral("-h"))) {
        printUsage();
        return 0;
    }

    RepairController controller;
    if (listRequested) {
        const QJsonObject output{
            {QStringLiteral("schema"), QStringLiteral("org.meo.repair-categories/v1")},
            {QStringLiteral("categories"), QJsonArray::fromVariantList(controller.checkCategories())}
        };
        QTextStream(stdout) << QJsonDocument(output).toJson(QJsonDocument::Indented);
        return 0;
    }
    if (cliRequested) {
        const QString category = optionValue(arguments, QStringLiteral("--category"),
                                             QStringLiteral("all"));
        bool completed = false;
        QObject::connect(&controller, &RepairController::quickCheckFinished, &app,
                         [&controller, &app, &completed](int exitCode) {
            completed = true;
            const QJsonObject output{
                {QStringLiteral("schema"), QStringLiteral("org.meo.repair-check/v1")},
                {QStringLiteral("scope"), controller.liveEnvironment()
                     ? QStringLiteral("live") : QStringLiteral("system")},
                {QStringLiteral("category"), controller.selectedCategory()},
                {QStringLiteral("state"), controller.auditState()},
                {QStringLiteral("summary"), controller.auditSummary()},
                {QStringLiteral("findings"), QJsonArray::fromVariantList(controller.auditFindings())},
                {QStringLiteral("log"), controller.checkLog()}
            };
            QTextStream(stdout) << QJsonDocument(output).toJson(QJsonDocument::Indented);
            app.exit(exitCode == 0 ? 0 : 1);
        });
        QTimer timeout;
        timeout.setSingleShot(true);
        QObject::connect(&timeout, &QTimer::timeout, &app, [&controller, &app, &completed] {
            if (completed)
                return;
            controller.cancelQuickCheck();
            QTextStream(stderr) << "Quick check timed out.\n";
            app.exit(124);
        });
        timeout.start(10 * 60 * 1000);
        QTimer::singleShot(0, &controller, [&controller, category] {
            controller.startQuickCheck(category);
        });
        return app.exec();
    }

    auto *guiApp = qobject_cast<QGuiApplication *>(&app);
    if (!guiApp)
        return 2;
    QQmlApplicationEngine engine;
    const QString configuredMeoUiPath = qEnvironmentVariable("MEO_UI_QML_IMPORT_PATH");
    if (!configuredMeoUiPath.isEmpty())
        engine.addImportPath(configuredMeoUiPath);
#ifdef MEOUI_QML_BUILD_IMPORT_PATH
    engine.addImportPath(QString::fromUtf8(MEOUI_QML_BUILD_IMPORT_PATH));
#endif
    engine.addImportPath(QStringLiteral("/usr/lib/qt6/qml"));

    QString qmlRoot = qEnvironmentVariable("MEOARCH_REPAIR_QML_ROOT");
    if (qmlRoot.isEmpty()) {
        const QString installed = QStringLiteral("/usr/lib/meoarch-repair/qml");
#ifdef MEOARCH_REPAIR_QML_SOURCE_DIR
        const QString development = QString::fromUtf8(MEOARCH_REPAIR_QML_SOURCE_DIR);
#else
        const QString development;
#endif
        qmlRoot = QFileInfo::exists(installed + QStringLiteral("/Main.qml"))
            ? installed : development;
    }
    engine.addImportPath(qmlRoot);
    QVariantMap initialProperties{
        {QStringLiteral("repairController"), QVariant::fromValue(&controller)},
        {QStringLiteral("visualPreview"), arguments.contains(QStringLiteral("--preview"))},
        {QStringLiteral("initialCategory"), optionValue(arguments, QStringLiteral("--category"),
                                                        QStringLiteral("all"))}
    };
    bool previewWidthIsValid = false;
    const int previewWidth = optionValue(arguments, QStringLiteral("--preview-width")).toInt(
        &previewWidthIsValid);
    if (arguments.contains(QStringLiteral("--preview")) && previewWidthIsValid
        && previewWidth >= 980 && previewWidth <= 4096) {
        initialProperties.insert(QStringLiteral("width"), previewWidth);
    }
    engine.setInitialProperties(initialProperties);
    engine.load(QUrl::fromLocalFile(QDir(qmlRoot).absoluteFilePath(QStringLiteral("Main.qml"))));
    if (engine.rootObjects().isEmpty())
        return 1;

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    if (window && arguments.contains(QStringLiteral("--kiosk")))
        window->showFullScreen();
    const QString screenshot = optionValue(arguments, QStringLiteral("--screenshot"));
    if (window && !screenshot.isEmpty()) {
        QTimer::singleShot(2200, window, [window, screenshot, &app] {
            const QImage image = window->grabWindow();
            app.exit(!image.isNull() && image.save(screenshot) ? 0 : 2);
        });
        QTimer::singleShot(8000, &app, [&app] { app.exit(3); });
    }
    return app.exec();
}
