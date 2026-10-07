#include "transactionvalidator.h"

#include <QStringList>

namespace
{
constexpr auto kLoginSessionEntryId = "session-entry.login.v1";

bool isBoolean(const QVariantMap &map, const QString &key)
{
    return !map.contains(key) || map.value(key).metaType().id() == QMetaType::Bool;
}

bool isString(const QVariantMap &map, const QString &key)
{
    return !map.contains(key) || map.value(key).metaType().id() == QMetaType::QString;
}
}

QVariantMap TransactionValidator::error(const QString &code, const QString &message)
{
    return {
        {QStringLiteral("ok"), false},
        {QStringLiteral("state"), QStringLiteral("rejected")},
        {QStringLiteral("errorCode"), code},
        {QStringLiteral("message"), message},
    };
}

QVariantMap TransactionValidator::inspect(const QString &kind, const QVariantMap &request)
{
    if (kind != QLatin1String("configuration")) {
        return error(QStringLiteral("unsupported-kind"),
                     QStringLiteral("Only configuration transactions are supported by this service version."));
    }
    return inspectConfiguration(request);
}

QVariantMap TransactionValidator::inspectConfiguration(const QVariantMap &request)
{
    static const QStringList allowedTopLevel{
        QStringLiteral("configurationId"),
        QStringLiteral("operation"),
        QStringLiteral("payload"),
    };
    for (auto it = request.constBegin(); it != request.constEnd(); ++it) {
        if (!allowedTopLevel.contains(it.key())) {
            return error(QStringLiteral("unknown-request-field"),
                         QStringLiteral("The configuration request contains an unsupported field: %1").arg(it.key()));
        }
    }

    const QString configurationId = request.value(QStringLiteral("configurationId")).toString().trimmed();
    if (configurationId != QLatin1String(kLoginSessionEntryId)) {
        return error(QStringLiteral("unsupported-configuration"),
                     QStringLiteral("This service version only supports session-entry.login.v1 inspection."));
    }

    const QString operation = request.value(QStringLiteral("operation"), QStringLiteral("inspect")).toString().trimmed();
    if (operation != QLatin1String("inspect") && operation != QLatin1String("plan")) {
        return error(QStringLiteral("read-only-service"),
                     QStringLiteral("Apply, commit, rollback and other mutations are not implemented by this service version."));
    }

    if (request.contains(QStringLiteral("payload"))
        && request.value(QStringLiteral("payload")).metaType().id() != QMetaType::QVariantMap) {
        return error(QStringLiteral("invalid-payload"),
                     QStringLiteral("Configuration payload must be a map."));
    }
    return inspectLoginSessionEntry(request);
}

QVariantMap TransactionValidator::inspectLoginSessionEntry(const QVariantMap &request)
{
    const QVariantMap payload = request.value(QStringLiteral("payload")).toMap();

    static const QStringList allowedPayload{
        QStringLiteral("schemaVersion"),
        QStringLiteral("scope"),
        QStringLiteral("appearance"),
        QStringLiteral("modules"),
        QStringLiteral("privacy"),
        QStringLiteral("layout"),
        QStringLiteral("motion"),
    };
    for (auto it = payload.constBegin(); it != payload.constEnd(); ++it) {
        if (!allowedPayload.contains(it.key())) {
            return error(QStringLiteral("unknown-payload-field"),
                         QStringLiteral("The login session-entry payload contains an unsupported field: %1").arg(it.key()));
        }
    }

    if (payload.contains(QStringLiteral("schemaVersion"))
        && payload.value(QStringLiteral("schemaVersion")).toInt() != 1) {
        return error(QStringLiteral("unsupported-schema-version"),
                     QStringLiteral("session-entry.login.v1 requires schemaVersion 1."));
    }
    if (payload.contains(QStringLiteral("scope"))
        && payload.value(QStringLiteral("scope")).toString() != QLatin1String("login")) {
        return error(QStringLiteral("invalid-scope"),
                     QStringLiteral("session-entry.login.v1 accepts only scope=login."));
    }

    for (const QString &section : {
             QStringLiteral("appearance"), QStringLiteral("modules"), QStringLiteral("privacy"),
             QStringLiteral("layout"), QStringLiteral("motion")}) {
        if (payload.contains(section) && payload.value(section).metaType().id() != QMetaType::QVariantMap) {
            return error(QStringLiteral("invalid-section"),
                         QStringLiteral("%1 must be a map.").arg(section));
        }
    }

    const QVariantMap modules = payload.value(QStringLiteral("modules")).toMap();
    for (const QString &key : {QStringLiteral("media"), QStringLiteral("weather"), QStringLiteral("audio")}) {
        if (!isBoolean(modules, key)) {
            return error(QStringLiteral("invalid-module-value"),
                         QStringLiteral("%1 must be a boolean.").arg(key));
        }
        if (modules.value(key, false).toBool()) {
            return error(QStringLiteral("login-private-module"),
                         QStringLiteral("Login scope does not permit media, weather, or audio session modules."));
        }
    }
    if (!isString(modules, QStringLiteral("weatherCity"))
        || !modules.value(QStringLiteral("weatherCity")).toString().isEmpty()) {
        return error(QStringLiteral("login-weather-city"),
                     QStringLiteral("Login scope requires an empty weatherCity."));
    }

    const QVariantMap privacy = payload.value(QStringLiteral("privacy")).toMap();
    if (privacy.contains(QStringLiteral("notificationVisibility"))
        && privacy.value(QStringLiteral("notificationVisibility")).toString() != QLatin1String("hidden")) {
        return error(QStringLiteral("login-notification-privacy"),
                     QStringLiteral("Login scope requires notificationVisibility=hidden."));
    }
    if (privacy.contains(QStringLiteral("showAlbumArtwork"))
        && (!isBoolean(privacy, QStringLiteral("showAlbumArtwork"))
            || privacy.value(QStringLiteral("showAlbumArtwork")).toBool())) {
        return error(QStringLiteral("login-album-artwork"),
                     QStringLiteral("Login scope requires showAlbumArtwork=false."));
    }
    if (privacy.contains(QStringLiteral("weatherLocation"))) {
        const QString location = privacy.value(QStringLiteral("weatherLocation")).toString();
        if (location != QLatin1String("hidden") && location != QLatin1String("city")) {
            return error(QStringLiteral("login-location-privacy"),
                         QStringLiteral("Login scope permits only hidden or city weatherLocation."));
        }
    }

    const QVariantMap appearance = payload.value(QStringLiteral("appearance")).toMap();
    if (appearance.contains(QStringLiteral("wallpaperMode"))
        && appearance.value(QStringLiteral("wallpaperMode")).toString() != QLatin1String("managed")) {
        return error(QStringLiteral("login-wallpaper-mode"),
                     QStringLiteral("Login scope requires wallpaperMode=managed."));
    }

    QVariantMap plan{
        {QStringLiteral("ok"), true},
        {QStringLiteral("state"), QStringLiteral("planned")},
        {QStringLiteral("kind"), QStringLiteral("configuration")},
        {QStringLiteral("configurationId"), QString::fromLatin1(kLoginSessionEntryId)},
        {QStringLiteral("operation"), QStringLiteral("inspect")},
        {QStringLiteral("mutable"), false},
        {QStringLiteral("authorizationRequired"), false},
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("scope"), QStringLiteral("login")},
        {QStringLiteral("nextPhase"), QStringLiteral("none-read-only-service")},
    };
    if (!payload.isEmpty()) {
        plan.insert(QStringLiteral("validatedPayload"), payload);
    }
    return plan;
}
