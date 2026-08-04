#include "installercontroller.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QNetworkInterface>
#include <QProcessEnvironment>
#include <QRegularExpression>
#include <QSaveFile>
#include <QStandardPaths>
#include <QTextStream>
#include <QTimeZone>
#include <QTimer>
#include <algorithm>

namespace {
QVariantMap row(std::initializer_list<std::pair<const char *, QVariant>> values)
{
    QVariantMap result;
    for (const auto &value : values)
        result.insert(QString::fromLatin1(value.first), value.second);
    return result;
}

QString utf8LocaleId(QString value)
{
    value = value.section(QRegularExpression(QStringLiteral("\\s+")), 0, 0).trimmed();
    value.replace(QStringLiteral(".utf8"), QStringLiteral(".UTF-8"), Qt::CaseInsensitive);
    return value;
}
}

InstallerController::InstallerController(const QStringList &arguments, QObject *parent)
    : QObject(parent),
      m_realInstallEnabled(arguments.contains(QStringLiteral("--enable-real-install"))),
      m_systemActionsEnabled(arguments.contains(QStringLiteral("--enable-system-actions")))
{
    m_selections = {
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("preferences"), QVariantMap{{QStringLiteral("uiLanguage"), QStringLiteral("en")}}},
        {QStringLiteral("locale"), QVariantMap{{QStringLiteral("systemLocale"), QStringLiteral("en_US.UTF-8")},
                                               {QStringLiteral("sysLanguage"), QStringLiteral("en_US")},
                                               {QStringLiteral("sysEncoding"), QStringLiteral("UTF-8")},
                                               {QStringLiteral("formatCountry"), QStringLiteral("US")},
                                               {QStringLiteral("formatLocale"), QStringLiteral("en_US.UTF-8")},
                                               {QStringLiteral("timezone"), QStringLiteral("UTC")},
                                               {QStringLiteral("keyboardLayout"), QStringLiteral("us")}}},
        {QStringLiteral("network"), QVariantMap{{QStringLiteral("mode"), QStringLiteral("networkmanager")}}},
        {QStringLiteral("software"), QVariantMap{{QStringLiteral("provider"), QStringLiteral("omnistore")},
                                                 {QStringLiteral("profiles"), QVariantList{}},
                                                 {QStringLiteral("launchOnFirstLogin"), true}}},
        {QStringLiteral("privacy"), QVariantMap{{QStringLiteral("diagnostics"), false},
                                                {QStringLiteral("firewall"), true},
                                                {QStringLiteral("securityUpdates"), true},
                                                {QStringLiteral("diskEncryption"), false},
                                                {QStringLiteral("restrictAppPermissions"), true}}},
        {QStringLiteral("disk"), QVariantMap{{QStringLiteral("mode"), QStringLiteral("erase")},
                                             {QStringLiteral("filesystem"), QStringLiteral("btrfs")},
                                             {QStringLiteral("swap"), QStringLiteral("zram")}}},
        {QStringLiteral("user"), QVariantMap{{QStringLiteral("automaticLogin"), false}}}
    };
    buildUiLanguages();
    buildSystemLocales();
    buildCountries();
    buildTimeZones();
    buildKeyboardLayouts();
    detectNetwork();
    refreshDisks();
    detectHardware();
}

QVariantMap InstallerController::section(const QString &name) const
{
    return m_selections.value(name).toMap();
}

void InstallerController::writeSelection(const QString &sectionName, const QString &key, const QVariant &value)
{
    QVariantMap data = section(sectionName);
    data.insert(key, value);
    m_selections.insert(sectionName, data);
    emit selectionsChanged();
}

QString InstallerController::uiLanguage() const { return section(QStringLiteral("preferences")).value(QStringLiteral("uiLanguage")).toString(); }
QString InstallerController::systemLocale() const { return section(QStringLiteral("locale")).value(QStringLiteral("systemLocale")).toString(); }
QString InstallerController::formatCountry() const { return section(QStringLiteral("locale")).value(QStringLiteral("formatCountry")).toString(); }
QString InstallerController::formatLocale() const { return section(QStringLiteral("locale")).value(QStringLiteral("formatLocale")).toString(); }
QString InstallerController::timeZone() const { return section(QStringLiteral("locale")).value(QStringLiteral("timezone")).toString(); }
QString InstallerController::keyboardLayout() const { return section(QStringLiteral("locale")).value(QStringLiteral("keyboardLayout")).toString(); }
QString InstallerController::selectedDisk() const { return section(QStringLiteral("disk")).value(QStringLiteral("stableId")).toString(); }

void InstallerController::setUiLanguage(const QString &id) { writeSelection(QStringLiteral("preferences"), QStringLiteral("uiLanguage"), id); }
void InstallerController::setSystemLocale(const QString &id)
{
    writeSelection(QStringLiteral("locale"), QStringLiteral("systemLocale"), id);
    writeSelection(QStringLiteral("locale"), QStringLiteral("sysLanguage"), id.section(QLatin1Char('.'), 0, 0));
}
void InstallerController::setFormatCountry(const QString &alpha2)
{
    writeSelection(QStringLiteral("locale"), QStringLiteral("formatCountry"), alpha2);
    const QString language = systemLocale().section(QLatin1Char('_'), 0, 0);
    const QString candidate = language + QLatin1Char('_') + alpha2 + QStringLiteral(".UTF-8");
    const bool exists = std::any_of(m_systemLocales.cbegin(), m_systemLocales.cend(), [&](const QVariant &entry) {
        return entry.toMap().value(QStringLiteral("id")).toString() == candidate;
    });
    writeSelection(QStringLiteral("locale"), QStringLiteral("formatLocale"), exists ? candidate : systemLocale());
}
void InstallerController::setTimeZone(const QString &id) { writeSelection(QStringLiteral("locale"), QStringLiteral("timezone"), id); }
void InstallerController::setKeyboardLayout(const QString &id) { writeSelection(QStringLiteral("locale"), QStringLiteral("keyboardLayout"), id); }
void InstallerController::setSelectedDisk(const QString &id)
{
    writeSelection(QStringLiteral("disk"), QStringLiteral("stableId"), id);
    for (const QVariant &entry : m_disks) {
        const QVariantMap disk = entry.toMap();
        if (disk.value(QStringLiteral("id")).toString() == id) {
            writeSelection(QStringLiteral("disk"), QStringLiteral("sizeBytes"),
                           disk.value(QStringLiteral("sizeBytes")));
            break;
        }
    }
}
void InstallerController::setSelection(const QString &s, const QString &key, const QVariant &value) { writeSelection(s, key, value); }
QVariant InstallerController::selection(const QString &s, const QString &key, const QVariant &fallback) const { return section(s).value(key, fallback); }

void InstallerController::buildUiLanguages()
{
    m_uiLanguages = {
        row({{"id", "en"}, {"nativeName", "English"}, {"englishName", "English"}, {"fontFallback", "Roboto"}}),
        row({{"id", "zh_CN"}, {"nativeName", QStringLiteral("简体中文")}, {"englishName", "Simplified Chinese"}, {"fontFallback", "Noto Sans SC"}}),
        row({{"id", "zh_TW"}, {"nativeName", QStringLiteral("繁體中文")}, {"englishName", "Traditional Chinese"}, {"fontFallback", "Noto Sans TC"}}),
        row({{"id", "ja"}, {"nativeName", QStringLiteral("日本語")}, {"englishName", "Japanese"}, {"fontFallback", "Noto Sans JP"}}),
        row({{"id", "ko"}, {"nativeName", QStringLiteral("한국어")}, {"englishName", "Korean"}, {"fontFallback", "Noto Sans KR"}}),
        row({{"id", "es"}, {"nativeName", "Español"}, {"englishName", "Spanish"}, {"fontFallback", "Roboto"}}),
        row({{"id", "fr"}, {"nativeName", "Français"}, {"englishName", "French"}, {"fontFallback", "Roboto"}}),
        row({{"id", "de"}, {"nativeName", "Deutsch"}, {"englishName", "German"}, {"fontFallback", "Roboto"}}),
        row({{"id", "pt_BR"}, {"nativeName", "Português (Brasil)"}, {"englishName", "Portuguese (Brazil)"}, {"fontFallback", "Roboto"}}),
        row({{"id", "ru"}, {"nativeName", QStringLiteral("Русский")}, {"englishName", "Russian"}, {"fontFallback", "Roboto"}}),
        row({{"id", "it"}, {"nativeName", "Italiano"}, {"englishName", "Italian"}, {"fontFallback", "Roboto"}})
    };
}

void InstallerController::buildSystemLocales()
{
    QSet<QString> seen;
    QFile file(QStringLiteral("/usr/share/i18n/SUPPORTED"));
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        while (!stream.atEnd()) {
            const QString id = utf8LocaleId(stream.readLine());
            if (id.isEmpty() || !id.contains(QStringLiteral("UTF-8"), Qt::CaseInsensitive) || seen.contains(id))
                continue;
            seen.insert(id);
            const QLocale locale(id.section(QLatin1Char('.'), 0, 0));
            const QString native = locale.nativeLanguageName();
            const QString localized = QLocale::languageToString(locale.language());
            m_systemLocales.append(row({{"id", id}, {"nativeName", native.isEmpty() ? localized : native},
                                        {"localizedName", localized}, {"code", id}}));
        }
    }
    if (m_systemLocales.isEmpty()) {
        const auto locales = QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, QLocale::AnyTerritory);
        for (const QLocale &locale : locales) {
            if (locale.territory() == QLocale::AnyTerritory)
                continue;
            QString id = locale.name() + QStringLiteral(".UTF-8");
            if (seen.contains(id))
                continue;
            seen.insert(id);
            m_systemLocales.append(row({{"id", id}, {"nativeName", locale.nativeLanguageName()},
                                        {"localizedName", QLocale::languageToString(locale.language())}, {"code", id}}));
        }
    }
    std::sort(m_systemLocales.begin(), m_systemLocales.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap().value(QStringLiteral("nativeName")).toString().localeAwareCompare(
                   b.toMap().value(QStringLiteral("nativeName")).toString()) < 0;
    });
}

void InstallerController::buildCountries()
{
    QFile file(QStringLiteral("/usr/share/iso-codes/json/iso_3166-1.json"));
    if (file.open(QIODevice::ReadOnly)) {
        const QJsonArray entries = QJsonDocument::fromJson(file.readAll()).object().value(QStringLiteral("3166-1")).toArray();
        for (const QJsonValue &value : entries) {
            const QJsonObject object = value.toObject();
            m_countries.append(row({{"alpha2", object.value(QStringLiteral("alpha_2")).toString()},
                                    {"alpha3", object.value(QStringLiteral("alpha_3")).toString()},
                                    {"name", object.value(QStringLiteral("name")).toString()},
                                    {"englishName", object.value(QStringLiteral("name")).toString()}}));
        }
    }
    if (m_countries.isEmpty()) {
        QSet<QString> seen;
        for (const QLocale &locale : QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, QLocale::AnyTerritory)) {
            const QString alpha2 = QLocale::territoryToCode(locale.territory());
            if (alpha2.size() != 2 || seen.contains(alpha2))
                continue;
            seen.insert(alpha2);
            m_countries.append(row({{"alpha2", alpha2}, {"alpha3", ""},
                                    {"name", QLocale::territoryToString(locale.territory())},
                                    {"englishName", QLocale::territoryToString(locale.territory())}}));
        }
    }
    std::sort(m_countries.begin(), m_countries.end(), [](const QVariant &a, const QVariant &b) {
        return a.toMap().value(QStringLiteral("name")).toString().localeAwareCompare(b.toMap().value(QStringLiteral("name")).toString()) < 0;
    });
}

void InstallerController::buildTimeZones()
{
    QString path = QStringLiteral("/usr/share/zoneinfo/zone1970.tab");
    if (!QFileInfo::exists(path))
        path = QStringLiteral("/usr/share/zoneinfo/zone.tab");
    QFile file(path);
    QSet<QString> seen;
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        while (!stream.atEnd()) {
            const QString line = stream.readLine();
            if (line.startsWith(QLatin1Char('#')) || line.trimmed().isEmpty())
                continue;
            const QStringList columns = line.split(QLatin1Char('\t'));
            if (columns.size() < 3 || seen.contains(columns.at(2)))
                continue;
            seen.insert(columns.at(2));
            const QString id = columns.at(2);
            const QTimeZone zone(id.toUtf8());
            const int offset = zone.offsetFromUtc(QDateTime::currentDateTimeUtc());
            const QString sign = offset < 0 ? QStringLiteral("-") : QStringLiteral("+");
            const int absolute = qAbs(offset);
            const QString offsetText = QStringLiteral("UTC%1%2:%3").arg(sign)
                .arg(absolute / 3600, 2, 10, QLatin1Char('0')).arg((absolute % 3600) / 60, 2, 10, QLatin1Char('0'));
            const QString city = id.section(QLatin1Char('/'), -1).replace(QLatin1Char('_'), QLatin1Char(' '));
            m_timeZones.append(row({{"id", id}, {"continent", id.section(QLatin1Char('/'), 0, 0)},
                                    {"city", city}, {"countryCodes", columns.at(0)}, {"offset", offsetText},
                                    {"label", city + QStringLiteral(" · ") + offsetText}}));
        }
    }
    if (m_timeZones.isEmpty()) {
        for (const QByteArray &zoneId : QTimeZone::availableTimeZoneIds()) {
            const QString id = QString::fromUtf8(zoneId);
            if (id.startsWith(QStringLiteral("Etc/GMT")) || id.startsWith(QStringLiteral("posix/")) || id.startsWith(QStringLiteral("right/")) || !id.contains(QLatin1Char('/')))
                continue;
            const QTimeZone zone(zoneId);
            const int offset = zone.offsetFromUtc(QDateTime::currentDateTimeUtc());
            const QString sign = offset < 0 ? QStringLiteral("-") : QStringLiteral("+");
            const int absolute = qAbs(offset);
            const QString offsetText = QStringLiteral("UTC%1%2:%3").arg(sign)
                .arg(absolute / 3600, 2, 10, QLatin1Char('0')).arg((absolute % 3600) / 60, 2, 10, QLatin1Char('0'));
            const QString city = id.section(QLatin1Char('/'), -1).replace(QLatin1Char('_'), QLatin1Char(' '));
            m_timeZones.append(row({{"id", id}, {"continent", id.section(QLatin1Char('/'), 0, 0)},
                                    {"city", city}, {"countryCodes", ""}, {"offset", offsetText},
                                    {"label", city + QStringLiteral(" · ") + offsetText}}));
        }
    }
    m_timeZones.prepend(row({{"id", "UTC"}, {"continent", "UTC"}, {"city", "UTC"},
                             {"countryCodes", ""}, {"offset", "UTC+00:00"}, {"label", "UTC · UTC+00:00"}}));
}

void InstallerController::buildKeyboardLayouts()
{
    QFile file(QStringLiteral("/usr/share/X11/xkb/rules/evdev.lst"));
    bool inLayout = false;
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        while (!stream.atEnd()) {
            const QString line = stream.readLine();
            if (line.startsWith(QStringLiteral("! layout"))) { inLayout = true; continue; }
            if (inLayout && line.startsWith(QLatin1Char('!'))) break;
            if (!inLayout || line.trimmed().isEmpty()) continue;
            const auto match = QRegularExpression(QStringLiteral("^\\s*(\\S+)\\s+(.+)$")).match(line);
            if (match.hasMatch())
                m_keyboardLayouts.append(row({{"id", match.captured(1)}, {"name", match.captured(2).trimmed()}}));
        }
    }
    if (m_keyboardLayouts.isEmpty()) {
        m_keyboardLayouts = {row({{"id", "us"}, {"name", "English (US)"}}), row({{"id", "gb"}, {"name", "English (UK)"}}),
                             row({{"id", "jp"}, {"name", "Japanese"}}), row({{"id", "de"}, {"name", "German"}}),
                             row({{"id", "fr"}, {"name", "French"}}), row({{"id", "es"}, {"name", "Spanish"}})};
    }
}

void InstallerController::detectNetwork()
{
    m_networkState = QStringLiteral("offline");
    for (const QNetworkInterface &interface : QNetworkInterface::allInterfaces()) {
        if (interface.flags().testFlag(QNetworkInterface::IsUp) && interface.flags().testFlag(QNetworkInterface::IsRunning)
            && !interface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            m_networkState = QStringLiteral("connected");
            break;
        }
    }
    emit networkStateChanged();
}

void InstallerController::retryNetwork() { detectNetwork(); }

void InstallerController::detectHardware()
{
#ifdef Q_OS_LINUX
    const QString detector = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/hardware.py"));
    if (!QFileInfo::exists(detector))
        return;
    QProcess process;
    process.start(QStringLiteral("python3"), {detector});
    if (!process.waitForFinished(6000) || process.exitCode() != 0)
        return;
    const QJsonObject result = QJsonDocument::fromJson(process.readAllStandardOutput()).object();
    const QJsonArray packages = result.value(QStringLiteral("packages")).toArray();
    QStringList names;
    for (const QJsonValue &package : packages)
        names.append(package.toString());
    if (!names.isEmpty())
        m_hardwareSummary = result.value(QStringLiteral("summary")).toString().toUpper()
                           + QStringLiteral(" · ") + names.join(QStringLiteral(", "));
#endif
}

void InstallerController::refreshDisks()
{
    m_disks.clear();
#ifdef Q_OS_LINUX
    QProcess process;
    process.start(QStringLiteral("lsblk"), {QStringLiteral("-J"), QStringLiteral("-b"), QStringLiteral("-o"),
                                            QStringLiteral("NAME,MODEL,SIZE,TYPE,ROTA,RM,MOUNTPOINTS")});
    process.waitForFinished(5000);
    const QJsonArray devices = QJsonDocument::fromJson(process.readAllStandardOutput()).object().value(QStringLiteral("blockdevices")).toArray();
    for (const QJsonValue &value : devices) {
        const QJsonObject d = value.toObject();
        if (d.value(QStringLiteral("type")).toString() != QStringLiteral("disk")) continue;
        const QString name = d.value(QStringLiteral("name")).toString();
        QString stableId = QStringLiteral("/dev/") + name;
        const QDir byId(QStringLiteral("/dev/disk/by-id"));
        for (const QFileInfo &entry : byId.entryInfoList(QDir::System | QDir::Files | QDir::NoDotAndDotDot)) {
            if (entry.symLinkTarget().endsWith(QLatin1Char('/') + name)) { stableId = entry.absoluteFilePath(); break; }
        }
        const qint64 size = d.value(QStringLiteral("size")).toVariant().toLongLong();
        m_disks.append(row({{"id", stableId}, {"name", d.value(QStringLiteral("model")).toString().trimmed().isEmpty() ? QStringLiteral("Storage device") : d.value(QStringLiteral("model")).toString().trimmed()},
                            {"sizeBytes", size},
                            {"size", QLocale().formattedDataSize(size)}, {"available", QStringLiteral("Capacity ") + QLocale().formattedDataSize(size)},
                            {"kind", d.value(QStringLiteral("rm")).toInt() ? QStringLiteral("Removable") : (d.value(QStringLiteral("rota")).toInt() ? QStringLiteral("HDD") : QStringLiteral("SSD"))}}));
    }
#endif
    if (m_disks.isEmpty()) {
        m_disks = {row({{"id", "preview-disk-0"}, {"name", "NVMe Solid State Drive"}, {"size", "512 GB"}, {"available", "382 GB available"}, {"kind", "SSD · Preview"}}),
                   row({{"id", "preview-disk-1"}, {"name", "External Storage"}, {"size", "1 TB"}, {"available", "740 GB available"}, {"kind", "Removable · Preview"}})};
    }
    emit disksChanged();
}

bool InstallerController::validateAccount(const QString &username, const QString &hostname,
                                          const QString &password, const QString &confirmation)
{
    if (!QRegularExpression(QStringLiteral("^[a-z_][a-z0-9_-]{0,31}$")).match(username).hasMatch()) {
        setError(QStringLiteral("Username must use lowercase letters, numbers, _ or -.")); return false;
    }
    if (!QRegularExpression(QStringLiteral("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$" )).match(hostname).hasMatch()) {
        setError(QStringLiteral("Computer name must be 1–63 lowercase letters, numbers or hyphens.")); return false;
    }
    if (password.size() < 8) { setError(QStringLiteral("Password must contain at least 8 characters.")); return false; }
    if (password != confirmation) { setError(QStringLiteral("Passwords do not match.")); return false; }
    setError({});
    return true;
}

bool InstallerController::setAccountPassword(const QString &password)
{
    if (password.size() < 8) {
        setError(QStringLiteral("Password must contain at least 8 characters."));
        return false;
    }
    QProcess process;
    process.start(QStringLiteral("openssl"),
                  {QStringLiteral("passwd"), QStringLiteral("-6"), QStringLiteral("-stdin")});
    if (!process.waitForStarted(5000)) {
        setError(QStringLiteral("Could not start the password hashing helper."));
        return false;
    }
    process.write(password.toUtf8());
    process.write("\n");
    process.closeWriteChannel();
    if (!process.waitForFinished(15000) || process.exitCode() != 0) {
        setError(QStringLiteral("Could not securely hash the account password."));
        return false;
    }
    m_userPasswordHash = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
    if (!m_userPasswordHash.startsWith(QStringLiteral("$6$"))) {
        m_userPasswordHash.clear();
        setError(QStringLiteral("The password hashing helper returned an invalid result."));
        return false;
    }
    setError({});
    return true;
}

QString InstallerController::sourceRoot() const
{
    const QString env = qEnvironmentVariable("MEOARCH_INSTALLER_ROOT");
    if (!env.isEmpty()) return env;
    return QStringLiteral("/opt/meoarch-installer");
}

QString InstallerController::generatePreview()
{
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    QDir().mkpath(directory);
    const QString path = QDir(directory).absoluteFilePath(QStringLiteral("selections.json"));
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) { setError(file.errorString()); return {}; }
    file.write(QJsonDocument(QJsonObject::fromVariantMap(m_selections)).toJson(QJsonDocument::Indented));
    if (!file.commit()) { setError(file.errorString()); return {}; }
#ifdef Q_OS_LINUX
    const QString generator = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/generate-config.py"));
    if (QFileInfo::exists(generator)) {
        if (m_userPasswordHash.isEmpty()) {
            setError(QStringLiteral("Set a valid account password before generating the installation plan."));
            return {};
        }
        const QString credentialsPath = QDir(directory).absoluteFilePath(QStringLiteral("credential-input.json"));
        QSaveFile credentials(credentialsPath);
        credentials.setDirectWriteFallback(false);
        if (!credentials.open(QIODevice::WriteOnly)) {
            setError(credentials.errorString());
            return {};
        }
        credentials.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner);
        credentials.write(QJsonDocument(QJsonObject{
            {QStringLiteral("userPasswordHash"), m_userPasswordHash}
        }).toJson(QJsonDocument::Compact));
        if (!credentials.commit()) {
            setError(credentials.errorString());
            return {};
        }
        QProcess process;
        process.start(QStringLiteral("python3"), {generator, QStringLiteral("--data-dir"), QDir(sourceRoot()).absoluteFilePath(QStringLiteral("data")),
                                                 QStringLiteral("--state-dir"), directory, QStringLiteral("--selections"), path,
                                                 QStringLiteral("--credentials"), credentialsPath});
        const bool finished = process.waitForFinished(15000);
        QFile::remove(credentialsPath);
        if (!finished || process.exitCode() != 0) {
            const QString details = QString::fromUtf8(process.readAllStandardError()).trimmed();
            setError(details.isEmpty()
                         ? QStringLiteral("Could not generate the Archinstall preview configuration.")
                         : details);
            return {};
        }
    }
#endif
    return path;
}

void InstallerController::confirmSummary()
{
    m_summaryConfirmed = true;
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    QDir().mkpath(directory);
    QFile marker(QDir(directory).absoluteFilePath(QStringLiteral("summary_confirmed")));
    if (marker.open(QIODevice::WriteOnly | QIODevice::Truncate))
        marker.write("confirmed\n");
}

void InstallerController::startInstallation()
{
    if (!m_summaryConfirmed) { setError(QStringLiteral("Review and confirm the summary before installing.")); return; }
    m_installationState = QStringLiteral("running");
    m_installationProgress = 0;
    emit installationChanged();
    if (!m_realInstallEnabled) {
        m_installationState = QStringLiteral("failed");
        setError(QStringLiteral("Real installation is disabled in preview mode."));
        emit installationChanged();
        return;
    }
    const QString script = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/run-archinstall.sh"));
    if (!QFileInfo::exists(script)) {
        setError(QStringLiteral("The Archinstall adapter is missing."));
        m_installationState = QStringLiteral("failed");
        emit installationChanged();
        return;
    }
    auto *process = new QProcess(this);
    process->setProcessEnvironment(QProcessEnvironment::systemEnvironment());
    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus status) {
        m_installationState = status == QProcess::NormalExit && exitCode == 0 ? QStringLiteral("complete") : QStringLiteral("failed");
        m_installationProgress = m_installationState == QStringLiteral("complete") ? 100 : m_installationProgress;
        if (m_installationState == QStringLiteral("failed"))
            setError(QString::fromUtf8(process->readAllStandardError()).trimmed());
        process->deleteLater();
        emit installationChanged();
    });
    process->start(script);
}

void InstallerController::requestRestart()
{
    if (m_systemActionsEnabled) QProcess::startDetached(QStringLiteral("systemctl"), {QStringLiteral("reboot")});
    else setError(QStringLiteral("Restart is disabled in preview mode."));
}
void InstallerController::requestShutdown()
{
    if (m_systemActionsEnabled) QProcess::startDetached(QStringLiteral("systemctl"), {QStringLiteral("poweroff")});
    else setError(QStringLiteral("Shut down is disabled in preview mode."));
}
void InstallerController::setError(const QString &message) { m_errorMessage = message; emit errorMessageChanged(); }
