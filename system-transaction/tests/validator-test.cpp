#include "transactionvalidator.h"

#include <QCoreApplication>
#include <QTextStream>

namespace
{
int fail(const QString &message)
{
    QTextStream(stderr) << message << '\n';
    return 1;
}
}

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);

    const QVariantMap validPayload{
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("scope"), QStringLiteral("login")},
        {QStringLiteral("modules"), QVariantMap{
            {QStringLiteral("media"), false},
            {QStringLiteral("weather"), false},
            {QStringLiteral("audio"), false},
            {QStringLiteral("weatherCity"), QString()},
        }},
        {QStringLiteral("privacy"), QVariantMap{
            {QStringLiteral("notificationVisibility"), QStringLiteral("hidden")},
            {QStringLiteral("showAlbumArtwork"), false},
            {QStringLiteral("weatherLocation"), QStringLiteral("hidden")},
        }},
        {QStringLiteral("appearance"), QVariantMap{
            {QStringLiteral("wallpaperMode"), QStringLiteral("managed")},
        }},
    };

    const QVariantMap request{
        {QStringLiteral("configurationId"), QStringLiteral("session-entry.login.v1")},
        {QStringLiteral("operation"), QStringLiteral("inspect")},
        {QStringLiteral("payload"), validPayload},
    };

    const QVariantMap valid = TransactionValidator::inspect(QStringLiteral("configuration"), request);
    if (!valid.value(QStringLiteral("ok")).toBool()
        || valid.value(QStringLiteral("state")).toString() != QStringLiteral("planned")
        || valid.value(QStringLiteral("mutable")).toBool()) {
        return fail(QStringLiteral("valid read-only login request was not planned"));
    }

    QVariantMap unsafeRequest = request;
    QVariantMap unsafePayload = validPayload;
    QVariantMap unsafePrivacy = unsafePayload.value(QStringLiteral("privacy")).toMap();
    unsafePrivacy[QStringLiteral("notificationVisibility")] = QStringLiteral("full-content");
    unsafePayload[QStringLiteral("privacy")] = unsafePrivacy;
    unsafeRequest[QStringLiteral("payload")] = unsafePayload;
    const QVariantMap unsafe = TransactionValidator::inspect(QStringLiteral("configuration"), unsafeRequest);
    if (unsafe.value(QStringLiteral("ok")).toBool()) {
        return fail(QStringLiteral("login notification content was not rejected"));
    }

    QVariantMap writeRequest = request;
    writeRequest[QStringLiteral("operation")] = QStringLiteral("apply");
    const QVariantMap write = TransactionValidator::inspect(QStringLiteral("configuration"), writeRequest);
    if (write.value(QStringLiteral("ok")).toBool()
        || write.value(QStringLiteral("errorCode")).toString() != QStringLiteral("read-only-service")) {
        return fail(QStringLiteral("mutating request was not rejected"));
    }

    const QVariantMap unknown = TransactionValidator::inspect(QStringLiteral("package"), request);
    if (unknown.value(QStringLiteral("ok")).toBool()) {
        return fail(QStringLiteral("unknown transaction kind was not rejected"));
    }

    return 0;
}
