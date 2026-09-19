#include "installercontroller.h"

#include <QCoreApplication>
#include <QCalendar>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileDevice>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJSValue>
#include <QLocale>
#include <QNetworkInterface>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QProcessEnvironment>
#include <QRegularExpression>
#include <QSaveFile>
#include <QSettings>
#include <QStandardPaths>
#include <QStorageInfo>
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

bool hasMountedFilesystem(const QJsonObject &device)
{
    // lsblk represents an unmounted device as [null] on some releases.  An
    // array being non-empty is not evidence of a mounted filesystem.
    for (const QJsonValue &mountpoint : device.value(QStringLiteral("mountpoints")).toArray()) {
        if (!mountpoint.toString().trimmed().isEmpty())
            return true;
    }
    return false;
}

bool hasMountedDescendant(const QJsonObject &device)
{
    if (hasMountedFilesystem(device))
        return true;
    for (const QJsonValue &child : device.value(QStringLiteral("children")).toArray()) {
        if (hasMountedDescendant(child.toObject()))
            return true;
    }
    return false;
}

QString conciseProcessFailure(QString output)
{
    // The backend writes diagnostics through tee so the persistent log and
    // GUI receive the same facts. Keep the GUI copy readable and bounded.
    output.remove(QRegularExpression(QStringLiteral("\\x1B\\[[0-?]*[ -/]*[@-~]")));
    // The generated credentials file contains a shadow-compatible password
    // hash. It must not turn into a GUI error if a backend diagnostic happens
    // to include it. Raw passwords are never passed on an argv, but redact a
    // hash-shaped value defensively as well.
    output.replace(QRegularExpression(QStringLiteral("\\$[156]\\$[^\\s:]+")),
                   QStringLiteral("[redacted password hash]"));
    const QStringList lines = output.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    QStringList tail;
    for (auto it = lines.crbegin(); it != lines.crend() && tail.size() < 8; ++it)
        tail.prepend(it->trimmed());
    return tail.join(QLatin1Char('\n')).left(1600);
}

bool hasVerifiedCompletionEvent(const QString &eventsPath, qint64 startOffset)
{
    QFile events(eventsPath);
    if (!events.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;
    // A failed prior run may have left a terminal event in the shared Live
    // state directory. Only events written after this backend process was
    // launched can authorize the current GUI session. If the backend rotated
    // the file, start at its new beginning instead.
    if (startOffset < 0 || startOffset > events.size())
        startOffset = 0;
    if (!events.seek(startOffset))
        return false;

    QJsonObject lastStage;
    while (!events.atEnd()) {
        const QByteArray line = events.readLine().trimmed();
        if (line.isEmpty())
            continue;
        QJsonParseError parseError;
        const QJsonDocument document = QJsonDocument::fromJson(line, &parseError);
        if (parseError.error != QJsonParseError::NoError || !document.isObject())
            continue;
        const QJsonObject event = document.object();
        if (event.value(QStringLiteral("event")).toString() == QStringLiteral("stage"))
            lastStage = event;
    }

    return lastStage.value(QStringLiteral("id")).toString() == QStringLiteral("complete")
           && lastStage.value(QStringLiteral("progress")).toInt(-1) == 100;
}

bool isSupportedNetworkHandoffProfile(const QString &path, const QString &type)
{
    // Only copy profiles that have a complete, portable interpretation in the
    // installed system. Do not silently degrade enterprise Wi-Fi, VPN, static
    // routing, or a credential-provider-owned connection.
    QSettings profile(path, QSettings::IniFormat);
    profile.beginGroup(QStringLiteral("ipv4"));
    const QString ipv4Method = profile.value(QStringLiteral("method"), QStringLiteral("auto")).toString();
    profile.endGroup();
    if (ipv4Method != QStringLiteral("auto"))
        return false;
    if (type == QStringLiteral("802-3-ethernet"))
        return true;

    profile.beginGroup(QStringLiteral("802-1x"));
    const bool enterprise = !profile.allKeys().isEmpty();
    profile.endGroup();
    if (enterprise)
        return false;
    profile.beginGroup(QStringLiteral("802-11-wireless-security"));
    const QString keyManagement = profile.value(QStringLiteral("key-mgmt")).toString();
    const bool hasWifiSecurity = !profile.allKeys().isEmpty();
    profile.endGroup();
    // No security group means open Wi-Fi. OWE, WPA2-PSK and WPA3-SAE are the
    // supported portable forms. Do not guess at a more complex profile.
    return !hasWifiSecurity || keyManagement == QStringLiteral("wpa-psk")
           || keyManagement == QStringLiteral("sae") || keyManagement == QStringLiteral("owe");
}
}

InstallerController::InstallerController(const QStringList &arguments, QObject *parent)
    : QObject(parent),
      m_productionMode(arguments.contains(QStringLiteral("--production"))),
      m_realInstallEnabled(m_productionMode && arguments.contains(QStringLiteral("--enable-real-install"))),
      m_systemActionsEnabled(m_productionMode && arguments.contains(QStringLiteral("--enable-system-actions")))
{
    const QLocale systemLocale = QLocale::system();
    // The installer exposes only its reviewed English and Simplified Chinese
    // catalogs. Start with the language of the Live session whenever it has a
    // matching catalog; the user can still choose either language explicitly.
    // The installer currently ships one Chinese catalog. Resolve every
    // Chinese system locale to it so a Chinese Live desktop never starts with
    // an English installer just because its region uses a different script.
    const QString initialUiLanguage = systemLocale.language() == QLocale::Chinese
        ? QStringLiteral("zh_CN") : QStringLiteral("en");
    m_connectivityManager = new QNetworkAccessManager(this);
    // The Live installer runs inside a single Cage kiosk surface, so spawning
    // Konsole/xterm does not provide a usable diagnostic path. Offer an
    // embedded command console instead. Commands are deliberately executed as
    // the unprivileged Live user with no_new_privs and an empty capability
    // bounding set; the root-owned installer process never exposes a root shell.
    m_diagnosticConsoleAvailable = QFileInfo(QStringLiteral("/usr/bin/setpriv")).isExecutable()
                                   && QFileInfo(QStringLiteral("/usr/bin/timeout")).isExecutable()
                                   && QFileInfo(QStringLiteral("/usr/bin/env")).isExecutable()
                                   && QFileInfo(QStringLiteral("/usr/bin/bash")).isExecutable();

    m_selections = {
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("preferences"), QVariantMap{{QStringLiteral("uiLanguage"), initialUiLanguage},
                                                      {QStringLiteral("secondaryCalendar"), QStringLiteral("none")},
                                                      {QStringLiteral("hebcalEnabled"), false}}},
        {QStringLiteral("locale"), QVariantMap{{QStringLiteral("systemLocale"), QStringLiteral("en_US.UTF-8")},
                                               {QStringLiteral("sysLanguage"), QStringLiteral("en_US")},
                                               {QStringLiteral("sysEncoding"), QStringLiteral("UTF-8")},
                                               {QStringLiteral("formatCountry"), QStringLiteral("US")},
                                               {QStringLiteral("formatLocale"), QStringLiteral("en_US.UTF-8")},
                                               {QStringLiteral("timezone"), QStringLiteral("UTC")},
                                               {QStringLiteral("keyboardLayout"), QStringLiteral("us")}}},
        {QStringLiteral("network"), QVariantMap{{QStringLiteral("mode"), QStringLiteral("networkmanager")},
                                                  {QStringLiteral("handoffEnabled"), false}}},
        {QStringLiteral("privacy"), QVariantMap{{QStringLiteral("firewall"), true}}},
        {QStringLiteral("software"), QVariantMap{{QStringLiteral("profile"), QStringLiteral("recommended")},
                                                   {QStringLiteral("channel"), QStringLiteral("stable")},
                                                   {QStringLiteral("mirror"), QStringLiteral("automatic")},
                                                   {QStringLiteral("components"), QVariantList{}},
                                                   {QStringLiteral("applications"), QVariantList{}}}},
        {QStringLiteral("disk"), QVariantMap{{QStringLiteral("mode"), QStringLiteral("erase")},
                                             {QStringLiteral("filesystem"), QStringLiteral("btrfs")},
                                             {QStringLiteral("swap"), QStringLiteral("zram")},
                                             {QStringLiteral("separateHome"), false},
                                             {QStringLiteral("rootSizeGiB"), 32}}},
        {QStringLiteral("user"), QVariantMap{{QStringLiteral("automaticLogin"), false}}}
    };
    m_hardwareSummary = tr("Automatic PCI detection will select graphics drivers.");
    buildUiLanguages();
    buildSystemLocales();
    buildCountries();
    buildTimeZones();
    loadRegionPresets();
    // UTC is a safe persisted fallback, but when the Live environment itself
    // has a real geographic zone use it as the initial map selection. This is
    // not geolocation and performs no network request.
    const QString detectedTimeZone = QString::fromUtf8(QTimeZone::systemTimeZoneId());
    const bool canVisualizeDetectedZone = std::any_of(m_timeZones.cbegin(), m_timeZones.cend(),
        [&detectedTimeZone](const QVariant &entry) {
            return entry.toMap().value(QStringLiteral("id")).toString() == detectedTimeZone;
        });
    if (canVisualizeDetectedZone) {
        QVariantMap locale = section(QStringLiteral("locale"));
        locale.insert(QStringLiteral("timezone"), detectedTimeZone);
        m_selections.insert(QStringLiteral("locale"), locale);
    }
    buildKeyboardLayouts();
    loadSoftwareCatalog();
    detectNetwork();
    refreshNetworkHandoff();
    refreshDisks();
    detectHardware();
}

QVariantMap InstallerController::section(const QString &name) const
{
    return m_selections.value(name).toMap();
}

void InstallerController::writeSelection(const QString &sectionName, const QString &key, const QVariant &value)
{
    if (m_installationState == QStringLiteral("running"))
        return;
    QVariant normalizedValue = value;
    const bool isSoftwareList = sectionName == QStringLiteral("software")
                                && (key == QStringLiteral("components")
                                    || key == QStringLiteral("applications"));
    if (isSoftwareList) {
        // QML passes a JavaScript Array through a generic QVariant as a
        // QJSValue. QJsonObject does not serialize that wrapper as an array,
        // so persist the concrete QVariantList at this native boundary.
        if (normalizedValue.metaType() == QMetaType::fromType<QJSValue>()) {
            const QJSValue scriptValue = normalizedValue.value<QJSValue>();
            if (!scriptValue.isArray()) {
                setError(tr("The selected software list is invalid. Go back and choose the components again."));
                return;
            }
            normalizedValue = scriptValue.toVariant(QJSValue::ConvertJSObjects);
        }
        if (normalizedValue.metaType() != QMetaType::fromType<QVariantList>()) {
            setError(tr("The selected software list is invalid. Go back and choose the components again."));
            return;
        }
        const QVariantList entries = normalizedValue.toList();
        for (const QVariant &entry : entries) {
            if (entry.metaType() != QMetaType::fromType<QString>()
                || entry.toString().trimmed().isEmpty()) {
                setError(tr("The selected software list is invalid. Go back and choose the components again."));
                return;
            }
        }
        normalizedValue = entries;
    }
    QVariantMap data = section(sectionName);
    if (data.value(key) == normalizedValue)
        return;
    data.insert(key, normalizedValue);
    m_selections.insert(sectionName, data);
    ++m_planRevision;
    discardGeneratedPlan();
    if (m_preflightState != QStringLiteral("idle") || !m_installPlan.isEmpty()) {
        m_preflightState = QStringLiteral("idle");
        m_preflightMessage = tr("Choices changed. Prepare the installation plan again.");
        m_installPlan.clear();
        m_summaryConfirmed = false;
        m_confirmedPlanRevision = 0;
        emit preflightChanged();
    }
    emit selectionsChanged();
}

void InstallerController::discardGeneratedPlan()
{
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    QFile::remove(QDir(directory).absoluteFilePath(QStringLiteral("summary_confirmed")));
    QFile::remove(QDir(directory).absoluteFilePath(QStringLiteral("preflight_status.json")));
    // These are inputs to the destructive backend, not historical logs. A stale
    // asynchronous writer is drained before another preparation may start, and
    // its completion callback removes any files it recreated after invalidation.
    for (const QString &name : {QStringLiteral("config_manifest.json"),
                               QStringLiteral("credential-input.json"),
                               QStringLiteral("generated/install-plan.json"),
                               QStringLiteral("generated/user_configuration.json"),
                               QStringLiteral("generated/user_credentials.json"),
                               QStringLiteral("generated/network-handoff.nmconnection")})
        QFile::remove(QDir(directory).absoluteFilePath(name));
}

void InstallerController::discardAccountPasswordHash()
{
    // Account hashing is asynchronous.  A completion from an older save must
    // never supply credentials for a newer account selection.
    ++m_accountHashRevision;
    m_userPasswordHash.clear();
}

QString InstallerController::uiLanguage() const { return section(QStringLiteral("preferences")).value(QStringLiteral("uiLanguage")).toString(); }
QString InstallerController::systemLocale() const { return section(QStringLiteral("locale")).value(QStringLiteral("systemLocale")).toString(); }
QString InstallerController::formatCountry() const { return section(QStringLiteral("locale")).value(QStringLiteral("formatCountry")).toString(); }
QString InstallerController::formatLocale() const { return section(QStringLiteral("locale")).value(QStringLiteral("formatLocale")).toString(); }
QString InstallerController::timeZone() const { return section(QStringLiteral("locale")).value(QStringLiteral("timezone")).toString(); }
QString InstallerController::keyboardLayout() const { return section(QStringLiteral("locale")).value(QStringLiteral("keyboardLayout")).toString(); }
QVariantMap InstallerController::regionRecommendation() const
{
    const QString country = formatCountry();
    const QVariantMap preset = m_regionPresets.value(country);
    return {
        {QStringLiteral("country"), country},
        {QStringLiteral("systemLocale"), systemLocale()},
        {QStringLiteral("formatLocale"), formatLocale()},
        {QStringLiteral("timeZone"), timeZone()},
        {QStringLiteral("keyboardLayout"), keyboardLayout()},
        {QStringLiteral("automatic"), !section(QStringLiteral("locale")).value(QStringLiteral("manualSystemLocale")).toBool()
                                     && !section(QStringLiteral("locale")).value(QStringLiteral("manualFormatLocale")).toBool()
                                     && !section(QStringLiteral("locale")).value(QStringLiteral("manualTimezone")).toBool()
                                     && !section(QStringLiteral("locale")).value(QStringLiteral("manualKeyboardLayout")).toBool()},
        {QStringLiteral("hasPreset"), !preset.isEmpty()}
    };
}

QVariantList InstallerController::calendarCapabilities() const
{
    // The installer never contacts a calendar service.  These are the only
    // display preferences it can safely persist for the installed desktop.
    const QCalendar islamicCivil(QStringLiteral("islamic-civil"));
    const QString islamicState = islamicCivil.isValid() ? QStringLiteral("ready") : QStringLiteral("unavailable");
    const QString islamicDescription = islamicCivil.isValid()
        ? tr("Local Qt calendar display")
        : tr("This Qt runtime does not provide the Islamic Civil calendar");
    return {
        row({{"id", "none"}, {"name", tr("No secondary calendar")}, {"state", "ready"},
             {"description", tr("Gregorian calendar only")}}),
        row({{"id", "buddhist"}, {"name", tr("Buddhist Era")}, {"state", "ready"},
             {"description", tr("Local display only; no online request")}}),
        row({{"id", "islamic-civil"}, {"name", tr("Islamic Civil calendar")}, {"state", islamicState},
             {"description", islamicDescription}}),
        row({{"id", "hebcal"}, {"name", tr("Online Hebrew calendar data")}, {"state", "needs-online-setup"},
             {"description", tr("After installation, you can turn on public holiday data for the Hebrew calendar.")}})
    };
}
QString InstallerController::selectedDisk() const { return section(QStringLiteral("disk")).value(QStringLiteral("stableId")).toString(); }

bool InstallerController::networkHandoffEnabled() const
{
    return section(QStringLiteral("network")).value(QStringLiteral("handoffEnabled"), false).toBool()
           && m_networkHandoffState == QStringLiteral("ready");
}

void InstallerController::setUiLanguage(const QString &id)
{
    // The host ships reviewed catalogs only for English and Simplified
    // Chinese. Keep unknown command-line or test input on the English
    // fallback instead of storing an id that no selector can represent.
    const QString language = QLocale(id).language() == QLocale::Chinese
        ? QStringLiteral("zh_CN") : QStringLiteral("en");
    writeSelection(QStringLiteral("preferences"), QStringLiteral("uiLanguage"), language);
    if (!section(QStringLiteral("locale")).value(QStringLiteral("manualSystemLocale")).toBool())
        applyRegionPreset(formatCountry());
    loadSoftwareCatalog();
    emit localizedContentChanged();
    emit uiLanguageChanged();
}

void InstallerController::retranslateUserFacingState()
{
    // The selected language changes only this application's process locale.
    // Rebuilding these presentation values is read-only: it neither changes a
    // chosen disk nor writes the installation plan.
    if (!m_hardwareDetected)
        m_hardwareSummary = tr("Automatic PCI detection will select graphics drivers.");

    if (m_networkState == QStringLiteral("checking"))
        m_networkDetail = tr("Checking Internet access and required package sources…");
    else if (m_networkState == QStringLiteral("online"))
        m_networkDetail = tr("Internet access and the MeoArch package source are ready.");
    else if (m_networkState == QStringLiteral("repository"))
        m_networkDetail = tr("Internet access is working, but the MeoArch package source could not be verified. Try again later or check the repository configuration.");
    else if (m_networkState == QStringLiteral("portal"))
        m_networkDetail = tr("This network may require a sign-in page before installation can continue.");
    else if (m_networkState == QStringLiteral("offline"))
        m_networkDetail = tr("Internet access could not be verified. Check the connection and try again.");
    else if (m_networkState == QStringLiteral("no-interface"))
        m_networkDetail = tr("No active network interface was detected.");
    else
        m_networkDetail = tr("Network status is unavailable.");

    loadSoftwareCatalog();
    refreshNetworkHandoff();
    if (!m_diskDetecting)
        refreshDisks();
    emit hardwareChanged();
    emit networkStateChanged();
    emit localizedContentChanged();
}
void InstallerController::setSystemLocale(const QString &id)
{
    markLocaleOverride(QStringLiteral("manualSystemLocale"));
    writeSelection(QStringLiteral("locale"), QStringLiteral("systemLocale"), id);
    writeSelection(QStringLiteral("locale"), QStringLiteral("sysLanguage"), id.section(QLatin1Char('.'), 0, 0));
}
void InstallerController::setFormatLocale(const QString &id)
{
    if (!hasSystemLocale(id)) {
        setError(tr("That regional format is not available."));
        return;
    }
    markLocaleOverride(QStringLiteral("manualFormatLocale"));
    writeSelection(QStringLiteral("locale"), QStringLiteral("formatLocale"), id);
}
void InstallerController::setFormatCountry(const QString &alpha2)
{
    writeSelection(QStringLiteral("locale"), QStringLiteral("formatCountry"), alpha2);
    applyRegionPreset(alpha2);
}
void InstallerController::setTimeZone(const QString &id) { markLocaleOverride(QStringLiteral("manualTimezone")); writeSelection(QStringLiteral("locale"), QStringLiteral("timezone"), id); }
void InstallerController::setKeyboardLayout(const QString &id) { markLocaleOverride(QStringLiteral("manualKeyboardLayout")); writeSelection(QStringLiteral("locale"), QStringLiteral("keyboardLayout"), id); }
void InstallerController::setSecondaryCalendar(const QString &id)
{
    const QStringList allowed{QStringLiteral("none"), QStringLiteral("buddhist"), QStringLiteral("islamic-civil"), QStringLiteral("hebcal")};
    if (!allowed.contains(id)) {
        setError(tr("That calendar is not available."));
        return;
    }
    writeSelection(QStringLiteral("preferences"), QStringLiteral("secondaryCalendar"), id);
    if (id != QStringLiteral("hebcal"))
        writeSelection(QStringLiteral("preferences"), QStringLiteral("hebcalEnabled"), false);
}
void InstallerController::setHebcalEnabled(const bool enabled)
{
    if (section(QStringLiteral("preferences")).value(QStringLiteral("secondaryCalendar")).toString() != QStringLiteral("hebcal")) {
        setError(tr("Choose the Hebrew calendar before enabling online data."));
        return;
    }
    writeSelection(QStringLiteral("preferences"), QStringLiteral("hebcalEnabled"), enabled);
}
void InstallerController::useRegionRecommendations()
{
    for (const QString &key : {QStringLiteral("manualSystemLocale"), QStringLiteral("manualFormatLocale"),
                               QStringLiteral("manualTimezone"), QStringLiteral("manualKeyboardLayout")})
        writeSelection(QStringLiteral("locale"), key, false);
    applyRegionPreset(formatCountry());
}
void InstallerController::setNetworkHandoffEnabled(const bool enabled)
{
    if (enabled && m_networkHandoffState != QStringLiteral("ready")) {
        setError(m_networkHandoffMessage);
        return;
    }
    writeSelection(QStringLiteral("network"), QStringLiteral("handoffEnabled"), enabled);
    emit networkHandoffChanged();
}

void InstallerController::disableNetworkHandoff()
{
    // Network transfer is privacy-sensitive and opt-in. If a previously
    // selected profile becomes unavailable, clear that explicit choice rather
    // than carrying stale credentials into plan generation.
    if (section(QStringLiteral("network")).value(QStringLiteral("handoffEnabled"), false).toBool())
        writeSelection(QStringLiteral("network"), QStringLiteral("handoffEnabled"), false);
}
void InstallerController::setSelectedDisk(const QString &id)
{
    for (const QVariant &entry : m_disks) {
        const QVariantMap disk = entry.toMap();
        if (disk.value(QStringLiteral("id")).toString() == id) {
            if (!disk.value(QStringLiteral("eligible")).toBool()) {
                setError(disk.value(QStringLiteral("unavailableReason")).toString());
                return;
            }
            writeSelection(QStringLiteral("disk"), QStringLiteral("stableId"), id);
            writeSelection(QStringLiteral("disk"), QStringLiteral("sizeBytes"),
                           disk.value(QStringLiteral("sizeBytes")));
            writeSelection(QStringLiteral("disk"), QStringLiteral("devicePath"),
                           disk.value(QStringLiteral("devicePath")));
            writeSelection(QStringLiteral("disk"), QStringLiteral("serial"),
                           disk.value(QStringLiteral("serial")));
            writeSelection(QStringLiteral("disk"), QStringLiteral("wwn"),
                           disk.value(QStringLiteral("wwn")));
            writeSelection(QStringLiteral("disk"), QStringLiteral("targetPartition"), QVariantMap{});
            writeSelection(QStringLiteral("disk"), QStringLiteral("efiPartition"), QVariantMap{});
            setError({});
            break;
        }
    }
}

void InstallerController::selectExistingPartition(const QString &diskId, const QString &partitionPath)
{
    for (const QVariant &entry : m_disks) {
        const QVariantMap disk = entry.toMap();
        if (disk.value(QStringLiteral("id")).toString() != diskId)
            continue;
        if (!disk.value(QStringLiteral("partitionInstallEligible")).toBool()) {
            setError(disk.value(QStringLiteral("partitionUnavailableReason")).toString());
            return;
        }
        QVariantMap root;
        QVariantMap efi;
        for (const QVariant &partitionEntry : disk.value(QStringLiteral("partitions")).toList()) {
            const QVariantMap partition = partitionEntry.toMap();
            if (partition.value(QStringLiteral("path")).toString() == partitionPath)
                root = partition;
            if (partition.value(QStringLiteral("eligibleEfi")).toBool() && efi.isEmpty())
                efi = partition;
        }
        if (root.isEmpty() || !root.value(QStringLiteral("eligibleRoot")).toBool()) {
            setError(tr("That partition cannot be used as the Meo root partition."));
            return;
        }
        if (efi.isEmpty()) {
            setError(tr("This disk needs an unmounted 512 MiB EFI System Partition. No partition will be changed."));
            return;
        }
        writeSelection(QStringLiteral("disk"), QStringLiteral("stableId"), diskId);
        writeSelection(QStringLiteral("disk"), QStringLiteral("sizeBytes"), disk.value(QStringLiteral("sizeBytes")));
        writeSelection(QStringLiteral("disk"), QStringLiteral("devicePath"), disk.value(QStringLiteral("devicePath")));
        writeSelection(QStringLiteral("disk"), QStringLiteral("serial"), disk.value(QStringLiteral("serial")));
        writeSelection(QStringLiteral("disk"), QStringLiteral("wwn"), disk.value(QStringLiteral("wwn")));
        writeSelection(QStringLiteral("disk"), QStringLiteral("targetPartition"), root);
        writeSelection(QStringLiteral("disk"), QStringLiteral("efiPartition"), efi);
        writeSelection(QStringLiteral("disk"), QStringLiteral("mode"), QStringLiteral("partition"));
        setError({});
        return;
    }
    setError(tr("The selected disk is no longer available. Refresh the disk list."));
}
void InstallerController::setSelection(const QString &s, const QString &key, const QVariant &value) { writeSelection(s, key, value); }
QVariant InstallerController::selection(const QString &s, const QString &key, const QVariant &fallback) const { return section(s).value(key, fallback); }

void InstallerController::loadSoftwareCatalog()
{
    m_softwareCatalog.clear();
    QFile file(QDir(sourceRoot()).absoluteFilePath(QStringLiteral("data/application-catalog.json")));
    if (!file.open(QIODevice::ReadOnly))
        return;
    QJsonParseError parseError;
    const QJsonObject root = QJsonDocument::fromJson(file.readAll(), &parseError).object();
    if (parseError.error != QJsonParseError::NoError || root.value(QStringLiteral("schemaVersion")).toInt() != 1)
        return;
    for (const QJsonValue &value : root.value(QStringLiteral("applications")).toArray()) {
        const QJsonObject application = value.toObject();
        const QJsonObject installer = application.value(QStringLiteral("installer")).toObject();
        if (installer.value(QStringLiteral("source")).toString() != QStringLiteral("arch-official"))
            continue;
        const QJsonObject translations = application.value(QStringLiteral("translations")).toObject();
        const QJsonObject localized = translations.value(uiLanguage()).toObject();
        m_softwareCatalog.append(QVariantMap{
            {QStringLiteral("id"), application.value(QStringLiteral("id")).toString()},
            {QStringLiteral("name"), localized.value(QStringLiteral("name")).toString(application.value(QStringLiteral("name")).toString())},
            {QStringLiteral("summary"), localized.value(QStringLiteral("summary")).toString(application.value(QStringLiteral("summary")).toString())},
            {QStringLiteral("category"), localized.value(QStringLiteral("category")).toString(application.value(QStringLiteral("category")).toString())},
            {QStringLiteral("package"), installer.value(QStringLiteral("package")).toString()},
            {QStringLiteral("tier"), installer.value(QStringLiteral("tier")).toString()},
            {QStringLiteral("profiles"), installer.value(QStringLiteral("profiles")).toArray().toVariantList()},
        });
    }
}

void InstallerController::buildUiLanguages()
{
    // UI language is deliberately independent from the locale written to the
    // installed system.  These are the two translations shipped and checked
    // with the installer; do not advertise a language merely because a system
    // locale happens to exist.
    m_uiLanguages = {
        row({{"id", "en"}, {"nativeName", "English"}, {"englishName", "English"}, {"fontFallback", "Roboto"}}),
        row({{"id", "zh_CN"}, {"nativeName", "简体中文"}, {"englishName", "Chinese (Simplified)"}, {"fontFallback", "Noto Sans CJK SC"}})
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

void InstallerController::loadRegionPresets()
{
    QFile file(QDir(sourceRoot()).absoluteFilePath(QStringLiteral("data/region-presets.json")));
    if (!file.open(QIODevice::ReadOnly))
        return;
    QJsonParseError error;
    const QJsonObject root = QJsonDocument::fromJson(file.readAll(), &error).object();
    if (error.error != QJsonParseError::NoError || root.value(QStringLiteral("schemaVersion")).toInt() != 1)
        return;
    const QJsonObject presets = root.value(QStringLiteral("presets")).toObject();
    for (auto it = presets.begin(); it != presets.end(); ++it)
        m_regionPresets.insert(it.key(), it.value().toObject().toVariantMap());
}

bool InstallerController::hasSystemLocale(const QString &id) const
{
    return std::any_of(m_systemLocales.cbegin(), m_systemLocales.cend(), [&id](const QVariant &entry) {
        return entry.toMap().value(QStringLiteral("id")).toString() == id;
    });
}

void InstallerController::markLocaleOverride(const QString &key)
{
    if (!section(QStringLiteral("locale")).value(key).toBool())
        writeSelection(QStringLiteral("locale"), key, true);
}

void InstallerController::applyRegionPreset(const QString &alpha2)
{
    const QVariantMap preset = m_regionPresets.value(alpha2);
    QVariantMap locale = section(QStringLiteral("locale"));
    const auto preferred = [&preset, this](const QString &key) {
        QString value = preset.value(key).toString();
        const QVariantMap byUiLanguage = preset.value(key + QStringLiteral("ByUiLanguage")).toMap();
        if (!byUiLanguage.isEmpty())
            value = byUiLanguage.value(uiLanguage(), byUiLanguage.value(QStringLiteral("en"))).toString();
        return value;
    };

    QString system = preferred(QStringLiteral("systemLocale"));
    if (system.isEmpty()) {
        const QString candidate = systemLocale().section(QLatin1Char('_'), 0, 0) + QLatin1Char('_') + alpha2 + QStringLiteral(".UTF-8");
        system = hasSystemLocale(candidate) ? candidate : systemLocale();
    }
    QString format = preferred(QStringLiteral("formatLocale"));
    if (format.isEmpty())
        format = system;
    const QString zone = preferred(QStringLiteral("timeZone"));
    const QString keyboard = preferred(QStringLiteral("keyboardLayout"));

    if (!locale.value(QStringLiteral("manualSystemLocale")).toBool() && hasSystemLocale(system)) {
        writeSelection(QStringLiteral("locale"), QStringLiteral("systemLocale"), system);
        writeSelection(QStringLiteral("locale"), QStringLiteral("sysLanguage"), system.section(QLatin1Char('.'), 0, 0));
    }
    if (!locale.value(QStringLiteral("manualFormatLocale")).toBool() && hasSystemLocale(format))
        writeSelection(QStringLiteral("locale"), QStringLiteral("formatLocale"), format);
    if (!locale.value(QStringLiteral("manualTimezone")).toBool() && !zone.isEmpty())
        writeSelection(QStringLiteral("locale"), QStringLiteral("timezone"), zone);
    if (!locale.value(QStringLiteral("manualKeyboardLayout")).toBool() && !keyboard.isEmpty())
        writeSelection(QStringLiteral("locale"), QStringLiteral("keyboardLayout"), keyboard);
}

void InstallerController::detectNetwork()
{
    ++m_connectivityGeneration;
    if (m_connectivityReply) {
        m_connectivityReply->abort();
        m_connectivityReply->deleteLater();
        m_connectivityReply = nullptr;
    }

    bool hasActiveInterface = false;
    for (const QNetworkInterface &interface : QNetworkInterface::allInterfaces()) {
        const auto flags = interface.flags();
        if (flags.testFlag(QNetworkInterface::IsUp)
            && flags.testFlag(QNetworkInterface::IsRunning)
            && !flags.testFlag(QNetworkInterface::IsLoopBack)) {
            hasActiveInterface = true;
            break;
        }
    }

    if (!hasActiveInterface) {
        m_networkState = QStringLiteral("no-interface");
        m_networkDetail = tr("No active network interface was detected.");
        emit networkStateChanged();
        refreshNetworkHandoff();
        return;
    }

    m_networkState = QStringLiteral("checking");
    m_networkDetail = tr("Checking Internet access…");
    emit networkStateChanged();

    const quint64 generation = m_connectivityGeneration;

    auto checkRepository = [this, generation] {
        if (generation != m_connectivityGeneration)
            return;

        m_networkDetail = tr("Internet access is working. Checking the MeoArch package source…");
        emit networkStateChanged();

        QNetworkRequest request(QUrl(QStringLiteral("https://packages.meoarch.org/meo/os/x86_64/meo.db")));
        request.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                             QNetworkRequest::NoLessSafeRedirectPolicy);
        request.setHeader(QNetworkRequest::UserAgentHeader,
                          QStringLiteral("MeoArch-Installer-Connectivity/3"));
        request.setRawHeader("Range", "bytes=0-0");

        QNetworkReply *reply = m_connectivityManager->get(request);
        m_connectivityReply = reply;
        QTimer::singleShot(10000, reply, [reply] {
            if (reply->isRunning())
                reply->abort();
        });

        connect(reply, &QNetworkReply::finished, this, [this, reply, generation] {
            if (generation != m_connectivityGeneration) {
                reply->deleteLater();
                return;
            }

            const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            if (reply->error() == QNetworkReply::NoError && status >= 200 && status < 300) {
                m_networkState = QStringLiteral("online");
                m_networkDetail = tr("Internet access and the MeoArch package source are ready.");
            } else {
                // The independent Arch probe already succeeded. A failure here
                // is a repository/CDN problem, not proof that the user's
                // Internet connection is offline.
                m_networkState = QStringLiteral("repository");
                m_networkDetail = tr("Internet access is working, but the MeoArch package source could not be verified. Try again later or check the repository configuration.");
            }

            m_connectivityReply = nullptr;
            emit networkStateChanged();
            refreshNetworkHandoff();
            reply->deleteLater();
        });
    };

    // Verify general Internet reachability independently from Meo infrastructure.
    // A one-byte GET avoids relying on HEAD behavior at mirrors and CDNs.
    QNetworkRequest internetRequest(QUrl(QStringLiteral(
        "https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db")));
    internetRequest.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                                 QNetworkRequest::NoLessSafeRedirectPolicy);
    internetRequest.setHeader(QNetworkRequest::UserAgentHeader,
                              QStringLiteral("MeoArch-Installer-Connectivity/3"));
    internetRequest.setRawHeader("Range", "bytes=0-0");

    QNetworkReply *internetReply = m_connectivityManager->get(internetRequest);
    m_connectivityReply = internetReply;
    QTimer::singleShot(10000, internetReply, [internetReply] {
        if (internetReply->isRunning())
            internetReply->abort();
    });

    connect(internetReply, &QNetworkReply::finished, this,
            [this, internetReply, generation, checkRepository] {
        if (generation != m_connectivityGeneration) {
            internetReply->deleteLater();
            return;
        }

        const int status = internetReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const bool internetReady = internetReply->error() == QNetworkReply::NoError
                                   && status >= 200 && status < 300;
        m_connectivityReply = nullptr;
        internetReply->deleteLater();

        if (!internetReady) {
            m_networkState = QStringLiteral("offline");
            m_networkDetail = tr("Internet access could not be verified. Check the connection and try again.");
            emit networkStateChanged();
            refreshNetworkHandoff();
            return;
        }

        checkRepository();
    });
}

void InstallerController::runDiagnosticCommand(const QString &command)
{
    const QString normalized = command.trimmed();
    if (!m_diagnosticConsoleAvailable) {
        setError(tr("The embedded diagnostic console is not available in this Live image."));
        return;
    }
    if (normalized.isEmpty() || m_diagnosticProcess)
        return;
    if (normalized.size() > 2048) {
        setError(tr("Diagnostic commands are limited to 2048 characters."));
        return;
    }

    m_diagnosticConsoleOutput += QStringLiteral("$ ") + normalized + QLatin1Char('\n');
    if (m_diagnosticConsoleOutput.size() > 65536)
        m_diagnosticConsoleOutput = m_diagnosticConsoleOutput.right(65536);
    emit diagnosticConsoleChanged();

    auto *process = new QProcess(this);
    m_diagnosticProcess = process;
    process->setProcessChannelMode(QProcess::MergedChannels);

    const QStringList arguments{
        QStringLiteral("--reuid=live"),
        QStringLiteral("--regid=live"),
        QStringLiteral("--clear-groups"),
        QStringLiteral("--no-new-privs"),
        QStringLiteral("/usr/bin/timeout"),
        QStringLiteral("--signal=TERM"),
        QStringLiteral("60s"),
        QStringLiteral("/usr/bin/env"),
        QStringLiteral("-i"),
        QStringLiteral("HOME=/home/live"),
        QStringLiteral("USER=live"),
        QStringLiteral("LOGNAME=live"),
        QStringLiteral("PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"),
        QStringLiteral("/usr/bin/bash"),
        QStringLiteral("--noprofile"),
        QStringLiteral("--norc"),
        QStringLiteral("-lc"),
        normalized
    };

    connect(process, &QProcess::readyReadStandardOutput, this, [this, process] {
        if (process != m_diagnosticProcess)
            return;
        m_diagnosticConsoleOutput += QString::fromUtf8(process->readAllStandardOutput());
        if (m_diagnosticConsoleOutput.size() > 65536)
            m_diagnosticConsoleOutput = m_diagnosticConsoleOutput.right(65536);
        emit diagnosticConsoleChanged();
    });
    connect(process, &QProcess::errorOccurred, this, [this, process](QProcess::ProcessError error) {
        if (process != m_diagnosticProcess || error != QProcess::FailedToStart)
            return;
        m_diagnosticConsoleOutput += tr("Could not start the diagnostic command.\n");
        m_diagnosticProcess = nullptr;
        emit diagnosticConsoleChanged();
        process->deleteLater();
    });
    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus status) {
        if (process != m_diagnosticProcess) {
            process->deleteLater();
            return;
        }
        const QByteArray remaining = process->readAllStandardOutput();
        if (!remaining.isEmpty())
            m_diagnosticConsoleOutput += QString::fromUtf8(remaining);
        if (status == QProcess::NormalExit)
            m_diagnosticConsoleOutput += tr("[exit %1]\n").arg(exitCode);
        else
            m_diagnosticConsoleOutput += tr("[command crashed]\n");
        if (m_diagnosticConsoleOutput.size() > 65536)
            m_diagnosticConsoleOutput = m_diagnosticConsoleOutput.right(65536);
        m_diagnosticProcess = nullptr;
        emit diagnosticConsoleChanged();
        process->deleteLater();
    });

    process->start(QStringLiteral("/usr/bin/setpriv"), arguments);
    emit diagnosticConsoleChanged();
}

void InstallerController::clearDiagnosticConsole()
{
    if (m_diagnosticProcess)
        return;
    m_diagnosticConsoleOutput.clear();
    emit diagnosticConsoleChanged();
}


void InstallerController::refreshNetworkHandoff()
{
    m_networkHandoffSource.clear();
    m_networkHandoffKind.clear();
    if (m_networkState != QStringLiteral("online")
        && m_networkState != QStringLiteral("repository")) {
        // The presentation getter makes an unavailable profile look disabled,
        // but installation consumes the persisted value directly. Clear the
        // default here too so an offline or portal-only Live session cannot
        // reach plan generation with a hidden, stale handoff request.
        disableNetworkHandoff();
        m_networkHandoffState = QStringLiteral("unavailable");
        m_networkHandoffMessage = tr("Connect to the Internet before this network can be remembered after installation.");
        emit networkHandoffChanged();
        return;
    }
    auto *process = new QProcess(this);
    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus status) {
        const QString output = QString::fromUtf8(process->readAllStandardOutput()).trimmed();
        process->deleteLater();
        if (status != QProcess::NormalExit || exitCode != 0 || output.isEmpty()) {
            disableNetworkHandoff();
            m_networkHandoffState = QStringLiteral("unsupported");
            m_networkHandoffMessage = tr("The active network cannot be safely transferred. Reconnect after installation.");
            emit networkHandoffChanged();
            return;
        }
        const QStringList fields = output.split(QLatin1Char(':'));
        if (fields.size() != 3 || (fields.at(2) != QStringLiteral("802-11-wireless") && fields.at(2) != QStringLiteral("802-3-ethernet"))) {
            disableNetworkHandoff();
            m_networkHandoffState = QStringLiteral("unsupported");
            m_networkHandoffMessage = tr("VPN, enterprise Wi-Fi, and advanced network profiles must be configured after installation.");
            emit networkHandoffChanged();
            return;
        }
        const QString source = fields.at(1);
        const QString prefix = QStringLiteral("/etc/NetworkManager/system-connections/");
        const QFileInfo info(source);
        if (!source.startsWith(prefix) || !info.isFile() || info.isSymLink() || !info.isReadable()) {
            disableNetworkHandoff();
            m_networkHandoffState = QStringLiteral("unsupported");
            m_networkHandoffMessage = tr("This NetworkManager profile is temporary or protected by another credential service.");
            emit networkHandoffChanged();
            return;
        }
        if (!isSupportedNetworkHandoffProfile(source, fields.at(2))) {
            disableNetworkHandoff();
            m_networkHandoffState = QStringLiteral("unsupported");
            m_networkHandoffMessage = tr("Only DHCP Ethernet, open Wi-Fi, WPA2/WPA3, and OWE can be remembered. Configure enterprise Wi-Fi, VPN, or static networking after installation.");
            emit networkHandoffChanged();
            return;
        }
        m_networkHandoffSource = source;
        m_networkHandoffKind = fields.at(2);
        m_networkHandoffState = QStringLiteral("ready");
        m_networkHandoffMessage = tr("This current network can be remembered after installation. Only this NetworkManager profile will be copied.");
        emit networkHandoffChanged();
    });
    process->start(QStringLiteral("nmcli"), {QStringLiteral("--terse"), QStringLiteral("--escape"), QStringLiteral("no"),
                                               QStringLiteral("--fields"), QStringLiteral("UUID,FILENAME,TYPE"),
                                               QStringLiteral("connection"), QStringLiteral("show"), QStringLiteral("--active")});
}

bool InstallerController::stageNetworkHandoff()
{
    const QString stateDirectory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation))
                                       .absoluteFilePath(QStringLiteral("meoarch-installer/generated"));
    const QString staged = QDir(stateDirectory).absoluteFilePath(QStringLiteral("network-handoff.nmconnection"));
    QFile::remove(staged);
    if (!section(QStringLiteral("network")).value(QStringLiteral("handoffEnabled"), false).toBool())
        return true;
    if (m_networkHandoffState != QStringLiteral("ready") || m_networkHandoffSource.isEmpty()) {
        setError(tr("The selected network can no longer be safely remembered. Turn off network transfer or reconnect."));
        return false;
    }
    QDir().mkpath(stateDirectory);
    if (!QFile::copy(m_networkHandoffSource, staged)) {
        setError(tr("Could not prepare the selected network for the installed system."));
        return false;
    }
    QFile handoff(staged);
    if (!handoff.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner)) {
        QFile::remove(staged);
        setError(tr("Could not protect the selected network handoff."));
        return false;
    }
    return true;
}

void InstallerController::detectHardware()
{
#ifdef Q_OS_LINUX
    const QString detector = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/hardware.py"));
    if (!QFileInfo::exists(detector))
        return;
    m_hardwareDetecting = true;
    emit hardwareChanged();
    auto *process = new QProcess(this);
    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus status) {
        m_hardwareDetecting = false;
        if (status == QProcess::NormalExit && exitCode == 0) {
            const QJsonObject result = QJsonDocument::fromJson(process->readAllStandardOutput()).object();
            const QJsonArray packages = result.value(QStringLiteral("packages")).toArray();
            QStringList names;
            for (const QJsonValue &package : packages)
                names.append(package.toString());
            if (!names.isEmpty())
                m_hardwareDetected = true;
            if (!names.isEmpty())
                m_hardwareSummary = result.value(QStringLiteral("summary")).toString().toUpper()
                                   + QStringLiteral(" · ") + names.join(QStringLiteral(", "));
        }
        process->deleteLater();
        emit hardwareChanged();
    });
    process->start(QStringLiteral("python3"), {detector});
#endif
}

void InstallerController::refreshDisks()
{
    if (m_diskDetecting)
        return;

    m_diskDetecting = true;
    m_disks.clear();
    emit diskDetectionChanged();
    emit disksChanged();
#ifdef Q_OS_LINUX
    auto *process = new QProcess(this);
    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus status) {
        if (status != QProcess::NormalExit || exitCode != 0) {
            setError(tr("Disk detection failed. No disk can be selected until the scan succeeds."));
            emit disksChanged();
        } else {
            parseDisks(process->readAllStandardOutput());
        }
        m_diskDetecting = false;
        emit diskDetectionChanged();
        process->deleteLater();
    });
    connect(process, &QProcess::errorOccurred, this, [this, process](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart || !m_diskDetecting)
            return;
        setError(tr("Disk detection could not start. No disk can be selected until lsblk is available."));
        emit disksChanged();
        m_diskDetecting = false;
        emit diskDetectionChanged();
        process->deleteLater();
    });
    process->start(QStringLiteral("lsblk"), {QStringLiteral("-J"), QStringLiteral("-b"), QStringLiteral("-o"),
                                            QStringLiteral("NAME,PATH,MODEL,SERIAL,WWN,SIZE,TYPE,ROTA,RM,HOTPLUG,TRAN,MOUNTPOINTS,FSTYPE,PARTTYPE,PKNAME,START,PARTN,LOG-SEC")});
#else
    setError(tr("Disk detection is only available in the Linux installer environment."));
    emit disksChanged();
    m_diskDetecting = false;
    emit diskDetectionChanged();
#endif
}

void InstallerController::parseDisks(const QByteArray &payload)
{
    const QJsonDocument document = QJsonDocument::fromJson(payload);
    if (!document.isObject()) {
        setError(tr("Disk detection returned invalid data."));
        emit disksChanged();
        return;
    }
    const QJsonArray devices = document.object().value(QStringLiteral("blockdevices")).toArray();
    QString runningSource;
    if (QFile file(QStringLiteral("/proc/self/mountinfo")); file.open(QIODevice::ReadOnly | QIODevice::Text))
        runningSource = QString::fromUtf8(file.readAll());
    for (const QJsonValue &value : devices) {
        const QJsonObject d = value.toObject();
        if (d.value(QStringLiteral("type")).toString() != QStringLiteral("disk")) continue;
        const QString name = d.value(QStringLiteral("name")).toString();
        if (name == QStringLiteral("zram0"))
            continue;
        const QString devicePath = d.value(QStringLiteral("path")).toString(
            QStringLiteral("/dev/") + name);
        QString stableId = devicePath;
        const QDir byId(QStringLiteral("/dev/disk/by-id"));
        for (const QFileInfo &entry : byId.entryInfoList(QDir::System | QDir::Files | QDir::NoDotAndDotDot)) {
            if (entry.symLinkTarget().endsWith(QLatin1Char('/') + name)) { stableId = entry.absoluteFilePath(); break; }
        }
        const qint64 size = d.value(QStringLiteral("size")).toVariant().toLongLong();
        const bool removable = d.value(QStringLiteral("rm")).toInt() != 0 || d.value(QStringLiteral("hotplug")).toInt() != 0;
        const bool mounted = hasMountedDescendant(d);
        const bool runningMedia = runningSource.contains(QStringLiteral("/dev/") + name);
        const bool eligible = !removable && !mounted && !runningMedia;
        const bool partitionInstallEligible = !removable && !runningMedia;
        QString reason;
        if (runningMedia) reason = tr("This device contains the running installer.");
        else if (removable) reason = tr("Removable media cannot be selected for erase install.");
        else if (mounted) reason = tr("This device has mounted filesystems.");
        QVariantList partitions;
        const int logicalSectorSize = d.value(QStringLiteral("log-sec")).toVariant().toInt();
        const qint64 minimumRootBytes = 16LL * 1024 * 1024 * 1024;
        const qint64 minimumEfiBytes = 512LL * 1024 * 1024;
        const QString efiGuid = QStringLiteral("c12a7328-f81f-11d2-ba4b-00a0c93ec93b");
        for (const QJsonValue &childValue : d.value(QStringLiteral("children")).toArray()) {
            const QJsonObject child = childValue.toObject();
            if (child.value(QStringLiteral("type")).toString() != QStringLiteral("part"))
                continue;
            const qint64 partitionSize = child.value(QStringLiteral("size")).toVariant().toLongLong();
            const bool partitionMounted = hasMountedFilesystem(child);
            const QString parttype = child.value(QStringLiteral("parttype")).toString().toLower();
            const QString fstype = child.value(QStringLiteral("fstype")).toString().toLower();
            const bool isEfi = parttype == efiGuid;
            const bool eligibleRoot = partitionInstallEligible && !partitionMounted && !isEfi && partitionSize >= minimumRootBytes;
            const bool eligibleEfi = partitionInstallEligible && !partitionMounted && isEfi
                                     && partitionSize >= minimumEfiBytes
                                     && (fstype == QStringLiteral("vfat") || fstype == QStringLiteral("fat")
                                         || fstype == QStringLiteral("fat16") || fstype == QStringLiteral("fat32"));
            QString partitionReason;
            if (!partitionInstallEligible)
                partitionReason = runningMedia ? tr("This device contains the running installer.") : tr("Removable media cannot be selected.");
            else if (partitionMounted)
                partitionReason = tr("This partition is mounted.");
            else if (isEfi)
                partitionReason = tr("EFI System Partition — preserved for boot files.");
            else if (partitionSize < minimumRootBytes)
                partitionReason = tr("At least 16 GiB is required for the Meo root partition.");
            partitions.append(row({
                {"name", child.value(QStringLiteral("name")).toString()},
                {"path", child.value(QStringLiteral("path")).toString()},
                {"sizeBytes", partitionSize}, {"size", QLocale().formattedDataSize(partitionSize)},
                {"startSectors", child.value(QStringLiteral("start")).toVariant().toLongLong()},
                {"sizeSectors", logicalSectorSize > 0 ? partitionSize / logicalSectorSize : 0},
                {"logicalSectorSize", logicalSectorSize}, {"partn", child.value(QStringLiteral("partn")).toVariant().toInt()},
                {"fstype", fstype}, {"parttype", parttype}, {"mounted", partitionMounted},
                {"isEfi", isEfi}, {"eligibleRoot", eligibleRoot}, {"eligibleEfi", eligibleEfi},
                {"unavailableReason", partitionReason},
            }));
        }
        QString partitionReason;
        if (runningMedia) partitionReason = tr("This device contains the running installer.");
        else if (removable) partitionReason = tr("Removable media cannot be selected.");
        m_disks.append(row({{"id", stableId}, {"devicePath", devicePath}, {"name", d.value(QStringLiteral("model")).toString().trimmed().isEmpty() ? tr("Storage device") : d.value(QStringLiteral("model")).toString().trimmed()},
                            {"sizeBytes", size},
                            {"size", QLocale().formattedDataSize(size)}, {"available", tr("Capacity ") + QLocale().formattedDataSize(size)},
                            {"kind", removable ? tr("Removable") : (d.value(QStringLiteral("rota")).toInt() ? tr("HDD") : tr("SSD"))},
                            {"serial", d.value(QStringLiteral("serial")).toString()}, {"wwn", d.value(QStringLiteral("wwn")).toString()},
                            {"transport", d.value(QStringLiteral("tran")).toString()}, {"eligible", eligible}, {"unavailableReason", reason},
                            {"partitions", partitions}, {"partitionInstallEligible", partitionInstallEligible},
                            {"partitionUnavailableReason", partitionReason}}));
    }
    if (m_disks.isEmpty())
        setError(tr("No eligible installation disk was detected. Preview disks are never shown in production mode."));
    emit disksChanged();
}

bool InstallerController::validateAccount(const QString &username, const QString &hostname,
                                          const QString &password, const QString &confirmation)
{
    if (!QRegularExpression(QStringLiteral("^[a-z_][a-z0-9_-]{0,31}$")).match(username).hasMatch()) {
        setError(tr("Username must use lowercase letters, numbers, _ or -.")); return false;
    }
    if (!QRegularExpression(QStringLiteral("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$" )).match(hostname).hasMatch()) {
        setError(tr("Computer name must be 1–63 lowercase letters, numbers or hyphens.")); return false;
    }
    if (password.size() < 8) { setError(tr("Password must contain at least 8 characters.")); return false; }
    if (password != confirmation) { setError(tr("Passwords do not match.")); return false; }
    setError({});
    return true;
}

void InstallerController::saveAccount(const QString &fullName, const QString &username, const QString &hostname,
                                      const QString &password, const QString &confirmation)
{
    if (m_installationState == QStringLiteral("running")) {
        setError(tr("Account details cannot change while installation is running."));
        emit accountFailed();
        return;
    }
    discardAccountPasswordHash();
    if (!validateAccount(username, hostname, password, confirmation)) {
        emit accountFailed();
        return;
    }
    writeSelection(QStringLiteral("user"), QStringLiteral("fullName"), fullName.trimmed());
    writeSelection(QStringLiteral("user"), QStringLiteral("username"), username);
    writeSelection(QStringLiteral("user"), QStringLiteral("hostname"), hostname);
    auto *process = new QProcess(this);
    m_accountHashProcess = process;
    const quint64 revision = m_accountHashRevision;
    connect(process, &QProcess::started, this, [process, password] {
        process->write(password.toUtf8());
        process->write("\n");
        process->closeWriteChannel();
    });
    connect(process, &QProcess::errorOccurred, this, [this, process, revision](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart || revision != m_accountHashRevision || process != m_accountHashProcess)
            return;
        m_accountHashProcess = nullptr;
        process->deleteLater();
        setError(tr("Could not start the account password helper."));
        emit accountFailed();
    });
    connect(process, &QProcess::finished, this, [this, process, revision](int exitCode, QProcess::ExitStatus status) {
        if (revision != m_accountHashRevision || process != m_accountHashProcess) {
            process->deleteLater();
            return;
        }
        m_accountHashProcess = nullptr;
        if (status != QProcess::NormalExit || exitCode != 0) {
            setError(tr("Could not securely hash the account password."));
            process->deleteLater();
            emit accountFailed();
            return;
        }
        m_userPasswordHash = QString::fromUtf8(process->readAllStandardOutput()).trimmed();
        process->deleteLater();
        if (!m_userPasswordHash.startsWith(QStringLiteral("$6$"))) {
            m_userPasswordHash.clear();
            setError(tr("The password hashing helper returned an invalid result."));
            emit accountFailed();
            return;
        }
        setError({});
        emit accountReady();
    });
    process->start(QStringLiteral("openssl"),
                  {QStringLiteral("passwd"), QStringLiteral("-6"), QStringLiteral("-stdin")});
}

QString InstallerController::sourceRoot() const
{
    const QString env = qEnvironmentVariable("MEOARCH_INSTALLER_ROOT");
    if (!env.isEmpty()) return env;
    return QStringLiteral("/opt/meoarch-installer");
}

void InstallerController::persistSelections()
{
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    QDir().mkpath(directory);
    const QString path = QDir(directory).absoluteFilePath(QStringLiteral("selections.json"));
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) { setError(file.errorString()); return; }
    file.write(QJsonDocument(QJsonObject::fromVariantMap(m_selections)).toJson(QJsonDocument::Indented));
    if (!file.commit()) setError(file.errorString());
}

void InstallerController::setPreflight(const QString &state, const QString &message)
{
    m_preflightState = state;
    m_preflightMessage = message;
    emit preflightChanged();
}

bool InstallerController::loadGeneratedInstallPlan(const QString &directory)
{
    QFile file(QDir(directory).absoluteFilePath(QStringLiteral("generated/install-plan.json")));
    if (!file.open(QIODevice::ReadOnly)) {
        setError(tr("The generated Meo package plan is missing."));
        return false;
    }
    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        setError(tr("The generated Meo package plan is invalid."));
        return false;
    }
    const QVariantMap plan = document.object().toVariantMap();
    const QVariantMap repository = plan.value(QStringLiteral("repository")).toMap();
    const QVariantMap package = plan.value(QStringLiteral("package")).toMap();
    const QVariantMap applications = plan.value(QStringLiteral("applications")).toMap();
    if (plan.value(QStringLiteral("schemaVersion")).toInt() != 2
        || repository.value(QStringLiteral("repositories")).toList().isEmpty()
        || package.value(QStringLiteral("packages")).toList().isEmpty()
        || applications.value(QStringLiteral("source")).toString() != QStringLiteral("arch-official")) {
        setError(tr("The generated Meo package plan is incomplete."));
        return false;
    }
    m_installPlan = plan;
    emit preflightChanged();
    return true;
}

void InstallerController::prepareInstallation()
{
    if (m_installationState == QStringLiteral("running"))
        return;
    if (m_accountHashProcess) {
        setError(tr("The account password is still being prepared. Please wait a moment."));
        return;
    }
    if (m_preparationRunning) {
        setError(tr("The previous preparation is still finishing. Please retry shortly."));
        return;
    }
    ++m_planRevision;
    discardGeneratedPlan();
    setError({});
    m_installPlan.clear();
    m_summaryConfirmed = false;
    m_confirmedPlanRevision = 0;
    setPreflight(QStringLiteral("checking"), tr("Generating and validating the installation plan…"));
    if (!stageNetworkHandoff()) {
        setPreflight(QStringLiteral("failed"), m_errorMessage);
        return;
    }
    persistSelections();
    if (!m_errorMessage.isEmpty()) {
        setPreflight(QStringLiteral("failed"), m_errorMessage);
        return;
    }
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    const QString path = QDir(directory).absoluteFilePath(QStringLiteral("selections.json"));
#ifdef Q_OS_LINUX
    const QString generator = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/generate-config.py"));
    if (QFileInfo::exists(generator)) {
        if (m_userPasswordHash.isEmpty()) {
            setError(tr("Set a valid account password before generating the installation plan."));
            setPreflight(QStringLiteral("failed"), m_errorMessage);
            return;
        }
        const QString credentialsPath = QDir(directory).absoluteFilePath(QStringLiteral("credential-input.json"));
        QSaveFile credentials(credentialsPath);
        credentials.setDirectWriteFallback(false);
        if (!credentials.open(QIODevice::WriteOnly)) {
            setError(credentials.errorString());
            setPreflight(QStringLiteral("failed"), m_errorMessage);
            return;
        }
        credentials.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner);
        credentials.write(QJsonDocument(QJsonObject{
            {QStringLiteral("userPasswordHash"), m_userPasswordHash}
        }).toJson(QJsonDocument::Compact));
        if (!credentials.commit()) {
            setError(credentials.errorString());
            setPreflight(QStringLiteral("failed"), m_errorMessage);
            return;
        }
        auto *process = new QProcess(this);
        m_preparationRunning = true;
        const quint64 revision = m_planRevision;
        connect(process, &QProcess::errorOccurred, this, [this, process, credentialsPath, revision](QProcess::ProcessError error) {
            if (error != QProcess::FailedToStart)
                return;
            m_preparationRunning = false;
            QFile::remove(credentialsPath);
            process->deleteLater();
            discardGeneratedPlan();
            if (revision == m_planRevision)
                setPreflight(QStringLiteral("failed"), tr("Could not start the configuration generator."));
        });
        connect(process, &QProcess::finished, this, [this, process, credentialsPath, directory, revision](int exitCode, QProcess::ExitStatus status) {
            m_preparationRunning = false;
            QFile::remove(credentialsPath);
            const QString details = QString::fromUtf8(process->readAllStandardError()).trimmed();
            process->deleteLater();
            if (revision != m_planRevision) {
                discardGeneratedPlan();
                return;
            }
            if (status != QProcess::NormalExit || exitCode != 0) {
                setError(details.isEmpty() ? tr("Could not generate the Archinstall installation plan.") : details);
                setPreflight(QStringLiteral("failed"), m_errorMessage);
                return;
            }
            if (!loadGeneratedInstallPlan(directory)) {
                setPreflight(QStringLiteral("failed"), m_errorMessage);
                return;
            }
            startArchinstallPreflight();
        });
        process->start(QStringLiteral("python3"), {generator, QStringLiteral("--data-dir"), QDir(sourceRoot()).absoluteFilePath(QStringLiteral("data")),
                                                 QStringLiteral("--state-dir"), directory, QStringLiteral("--selections"), path,
                                                 QStringLiteral("--credentials"), credentialsPath});
        return;
    }
#endif
    setPreflight(QStringLiteral("failed"), tr("The Linux installation backend is unavailable."));
}

void InstallerController::startArchinstallPreflight()
{
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    const QString script = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/archinstall-preflight.sh"));
    if (!QFileInfo::exists(script)) {
        setPreflight(QStringLiteral("failed"), tr("The Archinstall preflight helper is missing."));
        return;
    }
    setPreflight(QStringLiteral("checking"), tr("Checking the generated Archinstall configuration…"));
    auto *process = new QProcess(this);
    m_preparationRunning = true;
    const quint64 revision = m_planRevision;
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("MEOARCH_INSTALLER_STATE_DIR"), directory);
    process->setProcessEnvironment(environment);
    connect(process, &QProcess::errorOccurred, this, [this, process, revision](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart)
            return;
        m_preparationRunning = false;
        process->deleteLater();
        discardGeneratedPlan();
        if (revision == m_planRevision)
            setPreflight(QStringLiteral("failed"), tr("Could not start the Archinstall preflight."));
    });
    connect(process, &QProcess::finished, this, [this, process, directory, revision](int exitCode, QProcess::ExitStatus status) {
        m_preparationRunning = false;
        process->deleteLater();
        if (revision != m_planRevision) {
            discardGeneratedPlan();
            return;
        }
        const QFile statusFile(QDir(directory).absoluteFilePath(QStringLiteral("preflight_status.json")));
        QString message = tr("The generated Archinstall configuration was rejected.");
        QString state = QStringLiteral("failed");
        if (status == QProcess::NormalExit && exitCode == 0 && statusFile.exists()) {
            QFile file(statusFile.fileName());
            if (file.open(QIODevice::ReadOnly)) {
                const QJsonObject result = QJsonDocument::fromJson(file.readAll()).object();
                message = result.value(QStringLiteral("message")).toString(message);
                if (result.value(QStringLiteral("state")).toString() == QStringLiteral("complete"))
                    state = QStringLiteral("ready");
            }
        }
        setPreflight(state, message);
    });
    process->start(script);
}

void InstallerController::confirmSummary()
{
    if (!readyToInstall()) {
        setError(tr("The installation plan is not ready. Resolve the preflight result first."));
        return;
    }
    m_summaryConfirmed = false;
    m_confirmedPlanRevision = 0;
    const QString directory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    if (!QDir().mkpath(directory)) {
        setError(tr("Could not create the installation state directory."));
        return;
    }
    QSaveFile marker(QDir(directory).absoluteFilePath(QStringLiteral("summary_confirmed")));
    marker.setDirectWriteFallback(false);
    if (!marker.open(QIODevice::WriteOnly)
        || !marker.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner)
        || marker.write("confirmed\n") < 0
        || !marker.commit()) {
        setError(tr("Could not record the summary confirmation."));
        return;
    }
    m_summaryConfirmed = true;
    m_confirmedPlanRevision = m_planRevision;
}

void InstallerController::startInstallation()
{
    if (m_installationState == QStringLiteral("running") || m_installationProcess) {
        setError(tr("Installation is already running."));
        return;
    }
    if (m_installationState == QStringLiteral("complete")) {
        setError(tr("Installation has already completed. Restart into the installed system instead."));
        return;
    }
    if (!m_summaryConfirmed || m_confirmedPlanRevision != m_planRevision || !readyToInstall()) {
        setError(tr("Review and confirm a ready installation plan before installing."));
        return;
    }
    m_installationProgress = 0;
    m_installationFailureDetails.clear();
    updateInstallation(QStringLiteral("running"), 0, QStringLiteral("preflight"), tr("Preparing installation."));
    if (!m_realInstallEnabled) {
        m_summaryConfirmed = false;
        m_confirmedPlanRevision = 0;
        updateInstallation(QStringLiteral("failed"), 0, QStringLiteral("blocked"), tr("Real installation is disabled outside production mode."));
        setPreflight(QStringLiteral("failed"), tr("Real installation is disabled. Generate a new plan only from an authorized production session."));
        setError(m_installationMessage);
        return;
    }
    const QString script = QDir(sourceRoot()).absoluteFilePath(QStringLiteral("backend/run-archinstall.sh"));
    if (!QFileInfo::exists(script)) {
        m_summaryConfirmed = false;
        m_confirmedPlanRevision = 0;
        setError(tr("The Archinstall adapter is missing."));
        updateInstallation(QStringLiteral("failed"), 0, QStringLiteral("blocked"), m_errorMessage);
        setPreflight(QStringLiteral("failed"), tr("The installation backend is missing. Return to a complete Live image before trying again."));
        return;
    }
    const QString stateDirectory = QDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation)).absoluteFilePath(QStringLiteral("meoarch-installer"));
    auto *process = new QProcess(this);
    m_installationProcess = process;
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("MEOARCH_INSTALLER_STATE_DIR"), stateDirectory);
    process->setProcessEnvironment(environment);
    process->setProcessChannelMode(QProcess::MergedChannels);
    const QString eventsPath = QDir(stateDirectory).absoluteFilePath(QStringLiteral("logs/install-events.jsonl"));
    const qint64 eventsStartOffset = QFileInfo(eventsPath).exists() ? QFileInfo(eventsPath).size() : 0;
    if (m_progressTimer) {
        m_progressTimer->stop();
        m_progressTimer->deleteLater();
    }
    m_progressTimer = new QTimer(this);
    m_progressTimer->setInterval(350);
    connect(m_progressTimer, &QTimer::timeout, this, [this, eventsPath, eventsStartOffset] {
        QFile events(eventsPath);
        if (!events.open(QIODevice::ReadOnly | QIODevice::Text))
            return;
        qint64 startOffset = eventsStartOffset;
        if (startOffset < 0 || startOffset > events.size())
            startOffset = 0;
        if (!events.seek(startOffset))
            return;
        QByteArray lastLine;
        while (!events.atEnd()) {
            const QByteArray line = events.readLine().trimmed();
            if (!line.isEmpty())
                lastLine = line;
        }
        const QJsonObject event = QJsonDocument::fromJson(lastLine).object();
        if (event.value(QStringLiteral("event")).toString() != QStringLiteral("stage"))
            return;
        const QJsonValue progressValue = event.value(QStringLiteral("progress"));
        if (!progressValue.isDouble())
            return;
        const int progress = progressValue.toInt();
        updateInstallation(QStringLiteral("running"), progress,
                           event.value(QStringLiteral("id")).toString(),
                           event.value(QStringLiteral("message")).toString());
    });
    m_progressTimer->start();
    const auto stopProgress = [this] {
        if (m_progressTimer) {
            m_progressTimer->stop();
            m_progressTimer->deleteLater();
            m_progressTimer = nullptr;
        }
    };
    connect(process, &QProcess::errorOccurred, this, [this, process, stopProgress](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart || process != m_installationProcess)
            return;
        stopProgress();
        m_installationProcess = nullptr;
        m_summaryConfirmed = false;
        m_confirmedPlanRevision = 0;
        m_installationFailureDetails = tr("The installation backend could not be started. Check the saved log and the Live image contents before retrying.");
        updateInstallation(QStringLiteral("failed"), m_installationProgress, m_installationStage, tr("Installation stopped."));
        setPreflight(QStringLiteral("failed"), tr("Installation did not start. Generate and validate a new plan before trying again."));
        setError(m_installationFailureDetails);
        process->deleteLater();
        emit installationChanged();
    });
    connect(process, &QProcess::finished, this, [this, process, eventsPath, eventsStartOffset, stopProgress](int exitCode, QProcess::ExitStatus status) {
        if (process != m_installationProcess) {
            process->deleteLater();
            return;
        }
        stopProgress();
        m_installationProcess = nullptr;
        if (status == QProcess::NormalExit && exitCode == 0 && hasVerifiedCompletionEvent(eventsPath, eventsStartOffset))
            updateInstallation(QStringLiteral("complete"), 100, QStringLiteral("complete"), tr("Installation complete."));
        else {
            m_summaryConfirmed = false;
            m_confirmedPlanRevision = 0;
            updateInstallation(QStringLiteral("failed"), m_installationProgress, m_installationStage, tr("Installation stopped."));
            m_installationFailureDetails = conciseProcessFailure(QString::fromUtf8(process->readAllStandardOutput()));
            if (status == QProcess::NormalExit && exitCode == 0 && m_installationFailureDetails.isEmpty())
                m_installationFailureDetails = tr("The installation backend exited without the verified completion event. The target is not marked complete.");
            if (m_installationFailureDetails.isEmpty())
                m_installationFailureDetails = tr("The installer process ended without a diagnostic line. Open the saved log before retrying.");
            setError(m_installationFailureDetails);
            setPreflight(QStringLiteral("failed"), tr("Installation did not complete. Generate and validate a new plan before trying again."));
        }
        process->deleteLater();
        emit installationChanged();
    });
    process->start(script);
}

void InstallerController::updateInstallation(const QString &state, int progress, const QString &stage, const QString &message)
{
    m_installationState = state;
    m_installationProgress = std::clamp(progress, m_installationProgress, 100);
    m_installationStage = stage;
    m_installationMessage = message;
    emit installationChanged();
}

void InstallerController::requestRestart()
{
    if (!m_systemActionsEnabled) {
        setError(tr("Restart is disabled in preview mode."));
        return;
    }
    if (m_installationState != QStringLiteral("complete")) {
        setError(tr("Restart is available only after target validation completes."));
        return;
    }
    if (!QProcess::startDetached(QStringLiteral("systemctl"), {QStringLiteral("reboot")}))
        setError(tr("Could not request a restart from the Live system."));
}
void InstallerController::requestShutdown()
{
    if (!m_systemActionsEnabled) {
        setError(tr("Shut down is disabled in preview mode."));
        return;
    }
    if (m_installationState != QStringLiteral("complete")) {
        setError(tr("Shut down is available only after target validation completes."));
        return;
    }
    if (!QProcess::startDetached(QStringLiteral("systemctl"), {QStringLiteral("poweroff")}))
        setError(tr("Could not request shutdown from the Live system."));
}
void InstallerController::setError(const QString &message) { m_errorMessage = message; emit errorMessageChanged(); }
