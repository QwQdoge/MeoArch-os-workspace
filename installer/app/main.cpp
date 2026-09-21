#include "installercontroller.h"

#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QImage>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>
#include <QWindow>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QTextStream>
#include <QTranslator>
#include <QQmlContext>
#include <KLocalizedQmlContext>
#include <algorithm>
#include <memory>

#ifdef Q_OS_UNIX
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

namespace {
bool hasProductionCapability()
{
#ifdef Q_OS_UNIX
    constexpr char capabilityPath[] = "/run/meoarch-installer/production-capability";
    const int descriptor = ::open(capabilityPath, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    if (descriptor < 0)
        return false;
    struct stat metadata {};
    const bool valid = ::fstat(descriptor, &metadata) == 0
                       && S_ISREG(metadata.st_mode)
                       && metadata.st_uid == 0
                       && metadata.st_gid == 0
                       && (metadata.st_mode & 0777) == 0600
                       && metadata.st_nlink == 1;
    ::close(descriptor);
    return valid;
#else
    return false;
#endif
}
}

int main(int argc, char *argv[])
{
    bool dumpRequested = false;
    bool repairRequested = false;
    for (int index = 1; index < argc; ++index)
    {
        const QString argument = QString::fromLocal8Bit(argv[index]);
        dumpRequested = dumpRequested || argument == QStringLiteral("--dump-catalog-counts");
        repairRequested = repairRequested || argument == QStringLiteral("--repair");
    }
    std::unique_ptr<QCoreApplication> application;
    if (dumpRequested)
        application = std::make_unique<QCoreApplication>(argc, argv);
    else
        application = std::make_unique<QGuiApplication>(argc, argv);
    QCoreApplication &app = *application;
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArch"));
    QCoreApplication::setApplicationName(repairRequested
                                             ? QStringLiteral("MeoArch Repair")
                                             : QStringLiteral("MeoArch Installer"));
    const QStringList arguments = app.arguments();

    // Work out the initial UI language before the controller is constructed.
    // Several controller properties are user-facing strings created during
    // construction (for example the initial network and debug-terminal
    // status).  Installing the catalog only after construction leaves those
    // values in English until the next backend update.
    const auto normalizedUiLanguage = [](const QString &candidate) {
        return QLocale(candidate).language() == QLocale::Chinese
            ? QStringLiteral("zh_CN") : QStringLiteral("en");
    };
    QString initialUiLanguage = normalizedUiLanguage(QLocale::system().name());
    for (const QString &argument : arguments) {
        if (argument.startsWith(QStringLiteral("--language=")))
            initialUiLanguage = normalizedUiLanguage(argument.mid(11));
    }

    QTranslator installerTranslator;
    QTranslator meoUiTranslator;
    const auto loadCatalogs = [&app, &installerTranslator, &meoUiTranslator](const QString &language) {
        app.removeTranslator(&installerTranslator);
        app.removeTranslator(&meoUiTranslator);
        if (language != QStringLiteral("zh_CN"))
            return;

        QStringList paths;
        const QString configured = qEnvironmentVariable("MEOARCH_INSTALLER_TRANSLATIONS");
        if (!configured.isEmpty())
            paths.append(configured);
        paths.append(QStringLiteral("/opt/meoarch-installer/translations"));
#ifdef MEOARCH_TRANSLATIONS_BUILD_DIR
        paths.append(QString::fromUtf8(MEOARCH_TRANSLATIONS_BUILD_DIR));
#endif
        for (const QString &path : paths) {
            if (installerTranslator.load(QStringLiteral("meoarch_zh_CN"), path)) {
                app.installTranslator(&installerTranslator);
                break;
            }
        }

        QStringList meoUiPaths;
        const QString configuredMeoUiTranslations = qEnvironmentVariable("MEOUI_TRANSLATIONS");
        if (!configuredMeoUiTranslations.isEmpty())
            meoUiPaths.append(configuredMeoUiTranslations);
#ifdef MEOUI_TRANSLATIONS_BUILD_DIR
        meoUiPaths.append(QString::fromUtf8(MEOUI_TRANSLATIONS_BUILD_DIR));
#endif
        meoUiPaths.append(QStringLiteral("/usr/share/meoui-qml/translations"));
        for (const QString &path : meoUiPaths) {
            if (meoUiTranslator.load(QStringLiteral("meoui_zh_CN"), path)) {
                app.installTranslator(&meoUiTranslator);
                break;
            }
        }
    };
    // This is a process-local default. It gives C++ and QML locale-sensitive
    // formatting the same initial language without mutating the Live desktop.
    QLocale::setDefault(QLocale(initialUiLanguage));
    loadCatalogs(initialUiLanguage);

    const bool productionRequested = arguments.contains(QStringLiteral("--production"));
    const bool previewRequested = arguments.contains(QStringLiteral("--preview"));
    const bool realInstallRequested = arguments.contains(QStringLiteral("--enable-real-install"));
    const bool systemActionsRequested = arguments.contains(QStringLiteral("--enable-system-actions"));
    const bool privilegedCapabilityRequested = realInstallRequested || systemActionsRequested;
    if (productionRequested && previewRequested) {
        QTextStream(stderr) << "--preview cannot be used with --production.\n";
        return 2;
    }

    if (privilegedCapabilityRequested && !productionRequested) {
        QTextStream(stderr) << "Production capabilities require --production.\n";
        return 2;
    }
    if (repairRequested && (productionRequested || privilegedCapabilityRequested)) {
        QTextStream(stderr) << "Repair mode cannot request installer production capabilities.\n";
        return 2;
    }
    if ((productionRequested || privilegedCapabilityRequested) && !hasProductionCapability()) {
        QTextStream(stderr) << "This production launch was not authorized by the MeoArch Live service.\n";
        return 2;
    }

    if (repairRequested) {
        QString repairProgram = qEnvironmentVariable("MEOARCH_REPAIR_APP");
        if (repairProgram.isEmpty())
            repairProgram = QStringLiteral("/usr/bin/meoarch-repair");
        if (!QFileInfo(repairProgram).isExecutable()) {
            const QString sibling = QDir(QCoreApplication::applicationDirPath())
                                        .absoluteFilePath(QStringLiteral("meoarch-repair"));
            if (QFileInfo(sibling).isExecutable())
                repairProgram = sibling;
        }
        if (!QFileInfo(repairProgram).isExecutable()) {
            QTextStream(stderr) << "MeoArch Quick Repair is not installed.\n";
            return 127;
        }
        QStringList forwarded = arguments.mid(1);
        forwarded.removeAll(QStringLiteral("--repair"));
        if (!forwarded.contains(QStringLiteral("--live")))
            forwarded.prepend(QStringLiteral("--live"));
        return QProcess::execute(repairProgram, forwarded);
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
    // Plasma's maintained timezone selector uses KDE's i18n helpers.  Install
    // the same QML context into the Cage installer host rather than making a
    // local fork of that component just to replace its translated labels.
    KLocalization::setupLocalizedContext(&engine);
    const auto loadLanguage = [&engine, &loadCatalogs, &normalizedUiLanguage](const QString &language) {
        const QString normalizedLanguage = normalizedUiLanguage(language);
        const QLocale locale(normalizedLanguage);
        // Keep date, time, and accessible QML formatting in step with the UI
        // language for this installer process only. This does not change the
        // Live system's desktop locale.
        QLocale::setDefault(locale);
        engine.setUiLanguage(locale.bcp47Name());
        loadCatalogs(normalizedLanguage);
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
                // Keep visual preview capable of opening every page, including
                // the completion screen at index 11. This affects preview
                // selection only; normal installer navigation is QML-owned.
                initialPage = std::clamp(requested, 0, 11);
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
        const QString qmlFile = QStringLiteral("/Main.qml");
        if (QFileInfo::exists(installed + qmlFile))
            qmlRoot = installed;
        else if (QFileInfo::exists(bundled + qmlFile))
            qmlRoot = bundled;
        else
            qmlRoot = development;
    }
    engine.addImportPath(qmlRoot);
    // Install the selected translator before the first QML object is created.
    // This prevents an English first frame from flashing before retranslate().
    loadLanguage(controller.uiLanguage());
    const QString rootQml = QStringLiteral("Main.qml");
    engine.load(QUrl::fromLocalFile(QDir(qmlRoot).absoluteFilePath(rootQml)));
    if (engine.rootObjects().isEmpty())
        return 1;
    QObject::connect(&controller, &InstallerController::uiLanguageChanged, &engine,
                     [&controller, &loadLanguage] {
                         loadLanguage(controller.uiLanguage());
                         controller.retranslateUserFacingState();
                     });

    // Do not dismiss Plymouth merely because Cage managed to exec this
    // process. The first swapped Qt Quick frame is the earliest point at which
    // the graphical handoff is actually visible to the user.
    if (productionRequested) {
        if (auto *quickWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst())) {
            auto firstFrameReady = std::make_shared<bool>(false);
            QObject::connect(quickWindow, &QQuickWindow::frameSwapped, quickWindow,
                             [firstFrameReady] {
                *firstFrameReady = true;
                QProcess::startDetached(QStringLiteral("/usr/lib/meoarch/meo-boot-status"),
                                        {QStringLiteral("stage"), QStringLiteral("ready")});
            }, Qt::SingleShotConnection);
            QTimer::singleShot(20000, quickWindow, [firstFrameReady, &app] {
                if (!*firstFrameReady)
                    app.exit(70);
            });
        }
    }

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
