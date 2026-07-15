#pragma once

#include <QObject>
#include <QProcess>
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
    Q_PROPERTY(QString selectedDisk READ selectedDisk NOTIFY selectionsChanged)
    Q_PROPERTY(QString installationState READ installationState NOTIFY installationChanged)
    Q_PROPERTY(int installationProgress READ installationProgress NOTIFY installationChanged)
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
    QString selectedDisk() const;
    QString installationState() const { return m_installationState; }
    int installationProgress() const { return m_installationProgress; }
    QString errorMessage() const { return m_errorMessage; }
    bool realInstallEnabled() const { return m_realInstallEnabled; }
    bool systemActionsEnabled() const { return m_systemActionsEnabled; }

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
    Q_INVOKABLE void retryNetwork();
    Q_INVOKABLE void refreshDisks();
    Q_INVOKABLE QString generatePreview();
    Q_INVOKABLE void confirmSummary();
    Q_INVOKABLE void startInstallation();
    Q_INVOKABLE void requestRestart();
    Q_INVOKABLE void requestShutdown();

signals:
    void selectionsChanged();
    void disksChanged();
    void networkStateChanged();
    void installationChanged();
    void errorMessageChanged();

private:
    void buildUiLanguages();
    void buildSystemLocales();
    void buildCountries();
    void buildTimeZones();
    void buildKeyboardLayouts();
    void detectNetwork();
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
    QString m_installationState = QStringLiteral("idle");
    QString m_errorMessage;
    int m_installationProgress = 0;
    bool m_realInstallEnabled = false;
    bool m_systemActionsEnabled = false;
    bool m_summaryConfirmed = false;
};
