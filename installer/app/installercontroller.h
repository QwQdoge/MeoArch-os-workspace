#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

class InstallerController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList uiLanguages READ uiLanguages CONSTANT)
    Q_PROPERTY(QVariantList systemLocales READ systemLocales CONSTANT)
    Q_PROPERTY(QVariantList countries READ countries CONSTANT)
    Q_PROPERTY(QVariantList timeZones READ timeZones CONSTANT)
    Q_PROPERTY(QVariantList keyboardLayouts READ keyboardLayouts CONSTANT)
    Q_PROPERTY(QVariantList disks READ disks NOTIFY disksChanged)
    Q_PROPERTY(QString uiLanguage READ uiLanguage NOTIFY selectionsChanged)
    Q_PROPERTY(QString systemLocale READ systemLocale NOTIFY selectionsChanged)
    Q_PROPERTY(QString formatCountry READ formatCountry NOTIFY selectionsChanged)
    Q_PROPERTY(QString formatLocale READ formatLocale NOTIFY selectionsChanged)
    Q_PROPERTY(QString timeZone READ timeZone NOTIFY selectionsChanged)
    Q_PROPERTY(QString keyboardLayout READ keyboardLayout NOTIFY selectionsChanged)
    Q_PROPERTY(QString networkState READ networkState NOTIFY networkStateChanged)
    Q_PROPERTY(QString networkDetail READ networkDetail NOTIFY networkStateChanged)
    Q_PROPERTY(QString selectedDisk READ selectedDisk NOTIFY selectionsChanged)
    Q_PROPERTY(QString hardwareSummary READ hardwareSummary NOTIFY hardwareChanged)
    Q_PROPERTY(bool hardwareDetecting READ hardwareDetecting NOTIFY hardwareChanged)
    Q_PROPERTY(QString installationState READ installationState NOTIFY installationChanged)
    Q_PROPERTY(int installationProgress READ installationProgress NOTIFY installationChanged)
    Q_PROPERTY(QString installationStage READ installationStage NOTIFY installationChanged)
    Q_PROPERTY(QString installationMessage READ installationMessage NOTIFY installationChanged)
    Q_PROPERTY(QString preflightState READ preflightState NOTIFY preflightChanged)
    Q_PROPERTY(QString preflightMessage READ preflightMessage NOTIFY preflightChanged)
    Q_PROPERTY(QVariantMap installPlan READ installPlan NOTIFY preflightChanged)
    Q_PROPERTY(bool readyToInstall READ readyToInstall NOTIFY preflightChanged)
    Q_PROPERTY(bool productionMode READ productionMode CONSTANT)
    Q_PROPERTY(bool previewMode READ previewMode CONSTANT)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool realInstallEnabled READ realInstallEnabled CONSTANT)
    Q_PROPERTY(bool systemActionsEnabled READ systemActionsEnabled CONSTANT)

public:
    explicit InstallerController(const QStringList &arguments, QObject *parent = nullptr);

    QVariantList uiLanguages() const { return m_uiLanguages; }
    QVariantList systemLocales() const { return m_systemLocales; }
    QVariantList countries() const { return m_countries; }
    QVariantList timeZones() const { return m_timeZones; }
    QVariantList keyboardLayouts() const { return m_keyboardLayouts; }
    QVariantList disks() const { return m_disks; }
    QString uiLanguage() const;
    QString systemLocale() const;
    QString formatCountry() const;
    QString formatLocale() const;
    QString timeZone() const;
    QString keyboardLayout() const;
    QString networkState() const { return m_networkState; }
    QString networkDetail() const { return m_networkDetail; }
    QString selectedDisk() const;
    QString hardwareSummary() const { return m_hardwareSummary; }
    bool hardwareDetecting() const { return m_hardwareDetecting; }
    QString installationState() const { return m_installationState; }
    int installationProgress() const { return m_installationProgress; }
    QString installationStage() const { return m_installationStage; }
    QString installationMessage() const { return m_installationMessage; }
    QString preflightState() const { return m_preflightState; }
    QString preflightMessage() const { return m_preflightMessage; }
    QVariantMap installPlan() const { return m_installPlan; }
    bool readyToInstall() const { return m_preflightState == QStringLiteral("ready"); }
    QString errorMessage() const { return m_errorMessage; }
    bool realInstallEnabled() const { return m_realInstallEnabled; }
    bool systemActionsEnabled() const { return m_systemActionsEnabled; }
    bool productionMode() const { return m_productionMode; }
    bool previewMode() const { return !m_productionMode; }

    Q_INVOKABLE void setUiLanguage(const QString &id);
    Q_INVOKABLE void setSystemLocale(const QString &id);
    Q_INVOKABLE void setFormatCountry(const QString &alpha2);
    Q_INVOKABLE void setTimeZone(const QString &id);
    Q_INVOKABLE void setKeyboardLayout(const QString &id);
    Q_INVOKABLE void setSelectedDisk(const QString &id);
    Q_INVOKABLE void setSelection(const QString &section, const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant selection(const QString &section, const QString &key, const QVariant &fallback = {}) const;
    Q_INVOKABLE bool validateAccount(const QString &username, const QString &hostname,
                                     const QString &password, const QString &confirmation);
    Q_INVOKABLE void saveAccount(const QString &fullName, const QString &username, const QString &hostname,
                                 const QString &password, const QString &confirmation);
    Q_INVOKABLE void retryNetwork();
    Q_INVOKABLE void refreshDisks();
    Q_INVOKABLE void prepareInstallation();
    Q_INVOKABLE void confirmSummary();
    Q_INVOKABLE void startInstallation();
    Q_INVOKABLE void requestRestart();
    Q_INVOKABLE void requestShutdown();

signals:
    void selectionsChanged();
    void uiLanguageChanged();
    void disksChanged();
    void networkStateChanged();
    void hardwareChanged();
    void preflightChanged();
    void accountReady();
    void accountFailed();
    void installationChanged();
    void errorMessageChanged();

private:
    void buildUiLanguages();
    void buildSystemLocales();
    void buildCountries();
    void buildTimeZones();
    void buildKeyboardLayouts();
    void detectNetwork();
    void detectHardware();
    void parseDisks(const QByteArray &payload);
    void persistSelections();
    void startArchinstallPreflight();
    void setPreflight(const QString &state, const QString &message);
    bool loadGeneratedInstallPlan(const QString &directory);
    void updateInstallation(const QString &state, int progress, const QString &stage, const QString &message);
    void setError(const QString &message);
    QString sourceRoot() const;
    QVariantMap section(const QString &name) const;
    void writeSelection(const QString &section, const QString &key, const QVariant &value);

    QVariantList m_uiLanguages;
    QVariantList m_systemLocales;
    QVariantList m_countries;
    QVariantList m_timeZones;
    QVariantList m_keyboardLayouts;
    QVariantList m_disks;
    QVariantMap m_selections;
    QString m_networkState = QStringLiteral("offline");
    QString m_networkDetail;
    QString m_hardwareSummary = QStringLiteral("Automatic PCI detection will select graphics drivers.");
    bool m_hardwareDetecting = false;
    QString m_installationState = QStringLiteral("idle");
    QString m_errorMessage;
    int m_installationProgress = 0;
    QString m_installationStage;
    QString m_installationMessage;
    QString m_preflightState = QStringLiteral("idle");
    QString m_preflightMessage;
    QVariantMap m_installPlan;
    bool m_productionMode = false;
    bool m_realInstallEnabled = false;
    bool m_systemActionsEnabled = false;
    bool m_summaryConfirmed = false;
    QString m_userPasswordHash;
    QTimer *m_progressTimer = nullptr;
};
