#include "repaircontroller.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QSettings>
#include <QTextStream>
#include <QTimer>
#include <QTranslator>
#include <memory>

class UiLanguageController final : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE void select(const QString &preference)
    {
        emit languageRequested(preference);
    }

signals:
    void languageRequested(const QString &preference);
};

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

bool supportsSimplifiedChinese(const QLocale &locale)
{
    return locale.language() == QLocale::Chinese
           && locale.script() != QLocale::TraditionalHanScript;
}

QString normalizedUiLanguagePreference(const QString &requested)
{
    const QString preference = requested.trimmed();
    if (preference == QStringLiteral("system"))
        return preference;
    return supportsSimplifiedChinese(QLocale(preference))
        ? QStringLiteral("zh_CN") : QStringLiteral("en_US");
}

QString resolvedUiLanguage(const QString &preference)
{
    const QLocale locale = preference == QStringLiteral("system")
        ? QLocale::system() : QLocale(preference);
    return supportsSimplifiedChinese(locale)
        ? QStringLiteral("zh_CN") : QStringLiteral("en_US");
}

void printUsage()
{
    QTextStream(stdout)
        << "MeoArch Quick Repair\n\n"
        << "  meoarch-repair                         Open the MeoUI graphical app\n"
        << "  meoarch-repair --category audio        Open the sound troubleshooting flow\n"
        << "  meoarch-repair --cli --category all    Run fixed read-only checks\n"
        << "  meoarch-repair --cli --category=all    Equivalent inline form\n"
        << "  meoarch-repair --list-categories       Print category metadata as JSON\n"
        << "  meoarch-repair --classify '没有声音'    Classify locally without running a check\n"
        << "  meoarch-repair --questions=audio       Print installed guided questions\n"
        << "  meoarch-repair --evaluate-guidance=display --answer=symptom:not_detected\n"
        << "                                          Evaluate one installed answer without changing the system\n"
        << "  --live                                  Use Live/target-aware behavior\n"
        << "  --kiosk                                 Request a full-screen window\n"
        << "  --preview-width N                       Width for a --preview screenshot\n"
        << "  --preview-height N                      Height for a --preview screenshot\n"
        << "  --ui-language en|zh_CN                 Override the UI language for this launch\n"
        << "  --preview-workflow repair-approval      Preview the final simple approval page\n";
}
}

int main(int argc, char *argv[])
{
    bool cliRequested = false;
    bool listRequested = false;
    bool classifyRequested = false;
    bool questionsRequested = false;
    bool guidanceRequested = false;
    bool helpRequested = false;
    bool liveRequested = false;
    for (int index = 1; index < argc; ++index) {
        const QString argument = QString::fromLocal8Bit(argv[index]);
        cliRequested = cliRequested || argument == QStringLiteral("--cli");
        listRequested = listRequested || argument == QStringLiteral("--list-categories");
        classifyRequested = classifyRequested || argument == QStringLiteral("--classify")
            || argument.startsWith(QStringLiteral("--classify="));
        questionsRequested = questionsRequested || argument == QStringLiteral("--questions")
            || argument.startsWith(QStringLiteral("--questions="));
        guidanceRequested = guidanceRequested || argument == QStringLiteral("--evaluate-guidance")
            || argument.startsWith(QStringLiteral("--evaluate-guidance="));
        helpRequested = helpRequested || argument == QStringLiteral("--help")
            || argument == QStringLiteral("-h");
        liveRequested = liveRequested || argument == QStringLiteral("--live");
    }
    if (liveRequested)
        qputenv("MEOARCH_REPAIR_SCOPE", "live");

    std::unique_ptr<QCoreApplication> application;
    if (cliRequested || listRequested || classifyRequested || questionsRequested
        || guidanceRequested || helpRequested)
        application = std::make_unique<QCoreApplication>(argc, argv);
    else
        application = std::make_unique<QGuiApplication>(argc, argv);
    QCoreApplication &app = *application;
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArch"));
    QCoreApplication::setApplicationName(QStringLiteral("MeoArch Repair"));
    const QStringList arguments = app.arguments();
    if (helpRequested) {
        printUsage();
        return 0;
    }

    RepairController controller;
    if (guidanceRequested) {
        const QString category = optionValue(arguments, QStringLiteral("--evaluate-guidance"))
                                     .trimmed().toLower();
        const QStringList answer = optionValue(arguments, QStringLiteral("--answer"))
                                       .trimmed().split(QLatin1Char(':'));
        if (answer.size() != 2 || answer.at(0).isEmpty() || answer.at(1).isEmpty()) {
            QTextStream(stderr) << "--answer requires question_id:option_id.\n";
            return 2;
        }
        controller.prepareGuidedCategory(category);
        controller.setGuidedAnswer(answer.at(0), answer.at(1));
        if (controller.selectedCategory() != category
            || controller.guidedAnswers().value(answer.at(0)).toString() != answer.at(1)) {
            QTextStream(stderr) << "The category, question, or answer is not in the installed runbook.\n";
            return 2;
        }
        const QJsonObject output{
            {QStringLiteral("schema"), QStringLiteral("org.meo.repair-guidance-evaluation/v1")},
            {QStringLiteral("category"), category},
            {QStringLiteral("answers"), QJsonObject::fromVariantMap(controller.guidedAnswers())},
            {QStringLiteral("automaticAudioRepairAllowed"), controller.audioGuidedRepairAllowed()},
            {QStringLiteral("automaticDisplayRepairAllowed"), controller.displayGuidedRepairAllowed()},
            {QStringLiteral("handoffMessage"), controller.guidedHandoffMessage()}
        };
        QTextStream(stdout) << QJsonDocument(output).toJson(QJsonDocument::Indented);
        return 0;
    }
    if (questionsRequested) {
        const QString category = optionValue(arguments, QStringLiteral("--questions")).trimmed().toLower();
        const QVariantList questions = controller.guidedQuestionsForCategory(category);
        if (questions.isEmpty()) {
            QTextStream(stderr) << "No valid guided questions are installed for that category.\n";
            return 2;
        }
        const QJsonObject output{
            {QStringLiteral("schema"), QStringLiteral("org.meo.repair-guided-questions/v1")},
            {QStringLiteral("category"), category},
            {QStringLiteral("questions"), QJsonArray::fromVariantList(questions)}
        };
        QTextStream(stdout) << QJsonDocument(output).toJson(QJsonDocument::Indented);
        return 0;
    }
    if (classifyRequested) {
        const QString problem = optionValue(arguments, QStringLiteral("--classify")).trimmed();
        if (problem.isEmpty()) {
            QTextStream(stderr) << "--classify requires a non-empty problem description.\n";
            return 2;
        }
        const QJsonObject output{
            {QStringLiteral("schema"), QStringLiteral("org.meo.repair-classification/v1")},
            {QStringLiteral("category"), controller.classifyProblem(problem)}
        };
        QTextStream(stdout) << QJsonDocument(output).toJson(QJsonDocument::Indented);
        return 0;
    }
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
    QSettings uiSettings;
    const QString commandLineUiLanguage = optionValue(arguments, QStringLiteral("--ui-language"));
    const QString uiLanguagePreference = commandLineUiLanguage.isEmpty()
        ? normalizedUiLanguagePreference(
            uiSettings.value(QStringLiteral("uiLanguagePreference"), QStringLiteral("system")).toString())
        : normalizedUiLanguagePreference(commandLineUiLanguage);
    QQmlApplicationEngine engine;
    UiLanguageController languageController;
    QTranslator repairTranslator;
    QTranslator meoUiTranslator;
    const auto loadUiLanguage = [&app, &engine, &repairTranslator, &meoUiTranslator](
                                    const QString &language) {
        app.removeTranslator(&repairTranslator);
        app.removeTranslator(&meoUiTranslator);

        const QLocale locale(language);
        // This scope is the Repair process only. It keeps dates, times, QML
        // accessibility text, and qsTr() in agreement without changing the
        // desktop-wide Plasma locale.
        QLocale::setDefault(locale);
        engine.setUiLanguage(locale.bcp47Name());
        if (locale.name() != QStringLiteral("zh_CN")) {
            // Repair's source strings are Simplified Chinese. The reviewed
            // English catalog is therefore the fallback for English and for
            // unsupported system locales.
            QStringList repairTranslationPaths;
            const QString configuredRepairTranslations = qEnvironmentVariable(
                "MEOARCH_REPAIR_TRANSLATIONS");
            if (!configuredRepairTranslations.isEmpty())
                repairTranslationPaths.append(configuredRepairTranslations);
#ifdef MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR
            repairTranslationPaths.append(
                QString::fromUtf8(MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR));
#endif
            repairTranslationPaths.append(
                QStringLiteral("/usr/share/meoarch-repair/translations"));
            for (const QString &path : repairTranslationPaths) {
                if (repairTranslator.load(QStringLiteral("meoarch_repair_en"), path)) {
                    app.installTranslator(&repairTranslator);
                    break;
                }
            }
            engine.retranslate();
            return;
        }

        // QML source text is Simplified Chinese, while the controller emits
        // English source text. Load the controller's reviewed Chinese catalog
        // before creating the QML root so dynamic audit results agree with the
        // selected UI language as well.
        QStringList repairTranslationPaths;
        const QString configuredRepairTranslations = qEnvironmentVariable(
            "MEOARCH_REPAIR_TRANSLATIONS");
        if (!configuredRepairTranslations.isEmpty())
            repairTranslationPaths.append(configuredRepairTranslations);
#ifdef MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR
        repairTranslationPaths.append(
            QString::fromUtf8(MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR));
#endif
        repairTranslationPaths.append(
            QStringLiteral("/usr/share/meoarch-repair/translations"));
        for (const QString &path : repairTranslationPaths) {
            if (repairTranslator.load(QStringLiteral("meoarch_repair_zh_CN"), path)) {
                app.installTranslator(&repairTranslator);
                break;
            }
        }

        QStringList meoUiTranslationPaths;
        const QString configuredMeoUiTranslations = qEnvironmentVariable("MEOUI_TRANSLATIONS");
        if (!configuredMeoUiTranslations.isEmpty())
            meoUiTranslationPaths.append(configuredMeoUiTranslations);
#ifdef MEOUI_TRANSLATIONS_BUILD_DIR
        meoUiTranslationPaths.append(QString::fromUtf8(MEOUI_TRANSLATIONS_BUILD_DIR));
#endif
        meoUiTranslationPaths.append(QStringLiteral("/usr/share/meoui-qml/translations"));
        for (const QString &path : meoUiTranslationPaths) {
            if (meoUiTranslator.load(QStringLiteral("meoui_zh_CN"), path)) {
                app.installTranslator(&meoUiTranslator);
                break;
            }
        }
        engine.retranslate();
    };
    const QString configuredMeoUiPath = qEnvironmentVariable("MEO_UI_QML_IMPORT_PATH");
    if (!configuredMeoUiPath.isEmpty())
        engine.addImportPath(configuredMeoUiPath);
    const QString configuredMeoSystemPath = qEnvironmentVariable("MEO_SYSTEM_QML_IMPORT_PATH");
    if (!configuredMeoSystemPath.isEmpty())
        engine.addImportPath(configuredMeoSystemPath);
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
    const QString activeUiLanguage = resolvedUiLanguage(uiLanguagePreference);
    // Load before the QML root is created, avoiding an English first frame
    // when the system or an explicit preference selects Simplified Chinese.
    loadUiLanguage(activeUiLanguage);
    QVariantMap initialProperties{
        {QStringLiteral("repairController"), QVariant::fromValue(&controller)},
        {QStringLiteral("uiLanguageController"), QVariant::fromValue(&languageController)},
        {QStringLiteral("visualPreview"), arguments.contains(QStringLiteral("--preview"))},
        {QStringLiteral("previewWizardStage"),
         optionValue(arguments, QStringLiteral("--preview-workflow"))},
        {QStringLiteral("initialCategory"), optionValue(arguments, QStringLiteral("--category"),
                                                        QStringLiteral("all"))},
        {QStringLiteral("uiLanguage"), activeUiLanguage},
        {QStringLiteral("uiLanguagePreference"), uiLanguagePreference}
    };
    bool previewWidthIsValid = false;
    const int previewWidth = optionValue(arguments, QStringLiteral("--preview-width")).toInt(
        &previewWidthIsValid);
    if (arguments.contains(QStringLiteral("--preview")) && previewWidthIsValid
        && previewWidth >= 980 && previewWidth <= 4096) {
        initialProperties.insert(QStringLiteral("width"), previewWidth);
    }
    bool previewHeightIsValid = false;
    const int previewHeight = optionValue(arguments, QStringLiteral("--preview-height")).toInt(
        &previewHeightIsValid);
    if (arguments.contains(QStringLiteral("--preview")) && previewHeightIsValid
        && previewHeight >= 720 && previewHeight <= 4096) {
        initialProperties.insert(QStringLiteral("height"), previewHeight);
    }
    engine.setInitialProperties(initialProperties);
    engine.load(QUrl::fromLocalFile(QDir(qmlRoot).absoluteFilePath(QStringLiteral("Main.qml"))));
    if (engine.rootObjects().isEmpty())
        return 1;

    auto *rootObject = engine.rootObjects().constFirst();
    QObject::connect(&languageController, &UiLanguageController::languageRequested, &app,
                     [&uiSettings, &loadUiLanguage, rootObject](const QString &requestedPreference) {
        const QString preference = normalizedUiLanguagePreference(requestedPreference);
        uiSettings.setValue(QStringLiteral("uiLanguagePreference"), preference);
        const QString language = resolvedUiLanguage(preference);
        loadUiLanguage(language);
        rootObject->setProperty("uiLanguagePreference", preference);
        rootObject->setProperty("uiLanguage", language);
    });

    auto *window = qobject_cast<QQuickWindow *>(rootObject);
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

#include "main.moc"
