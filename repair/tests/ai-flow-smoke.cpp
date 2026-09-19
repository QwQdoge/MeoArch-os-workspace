#include "repaircontroller.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QFile>
#include <QFileInfo>
#include <QHostAddress>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QSet>
#include <QSettings>
#include <QTcpServer>
#include <QTcpSocket>
#include <QTemporaryDir>
#include <QTextStream>
#include <QTimer>

#include <memory>

class FakePrivilegedRepairService final : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.meo.Repair1")

public slots:
    QVariantMap RestartNetworkManager()
    {
        const QString markerPath = qEnvironmentVariable("MEOARCH_REPAIR_SMOKE_MARKER");
        QFile marker(markerPath);
        if (!marker.open(QIODevice::WriteOnly | QIODevice::Truncate)
            || marker.write("MEOARCH_WRITE_ACTION_OK\n") < 0) {
            return QVariantMap{{QStringLiteral("success"), false},
                               {QStringLiteral("resultCode"), 1},
                               {QStringLiteral("summary"), QStringLiteral("The isolated typed method could not write its marker.")}};
        }
        marker.close();
        return QVariantMap{{QStringLiteral("success"), true},
                           {QStringLiteral("resultCode"), 0},
                           {QStringLiteral("summary"), QStringLiteral("Typed D-Bus action and isolated post-check passed.")}};
    }
};

namespace {
QByteArray httpResponse(const QJsonObject &object)
{
    const QByteArray body = QJsonDocument(object).toJson(QJsonDocument::Compact);
    return QByteArrayLiteral("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\nContent-Length: ")
        + QByteArray::number(body.size()) + QByteArrayLiteral("\r\n\r\n") + body;
}

QJsonObject ollamaEnvelope(const QJsonObject &content)
{
    return QJsonObject{
        {QStringLiteral("message"),
         QJsonObject{{QStringLiteral("content"),
                      QString::fromUtf8(QJsonDocument(content).toJson(QJsonDocument::Compact))}}}
    };
}

QString userPrompt(const QJsonObject &request)
{
    const QJsonArray messages = request.value(QStringLiteral("messages")).toArray();
    if (messages.size() != 2)
        return {};
    return messages.at(1).toObject().value(QStringLiteral("content")).toString();
}
}

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("MeoArchTests"));
    QCoreApplication::setApplicationName(QStringLiteral("repair-ai-flow-smoke"));

    const QString markerPath = qEnvironmentVariable("MEOARCH_REPAIR_SMOKE_MARKER");
    if (qEnvironmentVariable("MEOARCH_REPAIR_SMOKE_SANDBOX") != QStringLiteral("1")
        || markerPath.isEmpty() || !QFileInfo(markerPath).isAbsolute()
        || QFileInfo::exists(markerPath)) {
        QTextStream(stderr)
            << "FAIL: the write-action smoke must run inside its isolated harness\n";
        return 2;
    }

    QDBusConnection repairBus = QDBusConnection::systemBus();
    FakePrivilegedRepairService privilegedService;
    if (!repairBus.isConnected()
        || !repairBus.registerService(QStringLiteral("org.meo.Repair1"))
        || !repairBus.registerObject(QStringLiteral("/org/meo/Repair1"),
                                     &privilegedService,
                                     QDBusConnection::ExportAllSlots)) {
        QTextStream(stderr) << "FAIL: isolated typed repair service is unavailable\n";
        return 12;
    }

    QTemporaryDir settingsRoot;
    if (!settingsRoot.isValid())
        return 3;
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope,
                       settingsRoot.path());

    QTcpServer server;
    if (!server.listen(QHostAddress::LocalHost, 0))
        return 4;

    int providerRequests = 0;
    QStringList requestedModels;
    QObject::connect(&server, &QTcpServer::newConnection, &app, [&] {
        while (QTcpSocket *socket = server.nextPendingConnection()) {
            auto buffer = std::make_shared<QByteArray>();
            QObject::connect(socket, &QTcpSocket::readyRead, socket, [&, socket, buffer] {
                buffer->append(socket->readAll());
                const qsizetype headerEnd = buffer->indexOf("\r\n\r\n");
                if (headerEnd < 0)
                    return;
                const QByteArray headers = buffer->left(headerEnd);
                const QRegularExpression lengthPattern(
                    QStringLiteral("(?:^|\\r\\n)Content-Length: ([0-9]+)"),
                    QRegularExpression::CaseInsensitiveOption);
                const QRegularExpressionMatch lengthMatch = lengthPattern.match(
                    QString::fromLatin1(headers));
                if (!lengthMatch.hasMatch()) {
                    socket->disconnectFromHost();
                    return;
                }
                const qsizetype bodyLength = lengthMatch.captured(1).toLongLong();
                if (buffer->size() < headerEnd + 4 + bodyLength)
                    return;

                const QByteArray body = buffer->mid(headerEnd + 4, bodyLength);
                const QJsonObject request = QJsonDocument::fromJson(body).object();
                const QString model = request.value(QStringLiteral("model")).toString();
                requestedModels.append(model);
                ++providerRequests;

                QJsonObject responseContent;
                if (model == QStringLiteral("proposal-test")) {
                    responseContent = QJsonObject{
                        {QStringLiteral("schema"), QStringLiteral("org.meo.repair-plan/v1")},
                        {QStringLiteral("summary"), QStringLiteral("NetworkManager is inactive and can be restarted.")},
                        {QStringLiteral("diagnosis"), QJsonArray{QStringLiteral("The fixed diagnostic reported an inactive network manager.")}},
                        {QStringLiteral("actions"), QJsonArray{QJsonObject{
                            {QStringLiteral("id"), QStringLiteral("A1")},
                            {QStringLiteral("kind"), QStringLiteral("restart_network_manager")},
                            {QStringLiteral("reason"), QStringLiteral("Restart the fixed network service and run its post-checks.")}
                        }}},
                        {QStringLiteral("manualRecommendations"), QJsonArray{}}
                    };
                } else if (model == QStringLiteral("review-test")) {
                    const QRegularExpression hashPattern(
                        QStringLiteral("planSha256=([0-9a-f]{64})"));
                    const QRegularExpressionMatch hashMatch = hashPattern.match(userPrompt(request));
                    if (!hashMatch.hasMatch()) {
                        socket->disconnectFromHost();
                        return;
                    }
                    responseContent = QJsonObject{
                        {QStringLiteral("schema"), QStringLiteral("org.meo.repair-risk-review/v1")},
                        {QStringLiteral("planSha256"), hashMatch.captured(1)},
                        {QStringLiteral("verdict"), QStringLiteral("approve")},
                        {QStringLiteral("risks"), QJsonArray{}},
                        {QStringLiteral("requiredChanges"), QJsonArray{}}
                    };
                } else {
                    socket->disconnectFromHost();
                    return;
                }

                socket->write(httpResponse(ollamaEnvelope(responseContent)));
                socket->disconnectFromHost();
            });
            QObject::connect(socket, &QTcpSocket::disconnected,
                             socket, &QObject::deleteLater);
        }
    });

    RepairController controller;
    int consents = 0;
    bool executionStarted = false;
    int result = 1;

    QObject::connect(&controller, &RepairController::aiConsentReady, &app,
                     [&](const QVariantMap &summary) {
        const QString stage = summary.value(QStringLiteral("stage")).toString();
        const QUrl destination(summary.value(QStringLiteral("destination")).toString());
        if (!QSet<QString>{QStringLiteral("proposal"), QStringLiteral("review")}.contains(stage)
            || !QHostAddress(destination.host()).isLoopback()) {
            result = 5;
            app.quit();
            return;
        }
        ++consents;
        QTimer::singleShot(0, &controller, [&controller] {
            controller.resolveAiConsent(true);
        });
    });
    QObject::connect(&controller, &RepairController::quickCheckFinished, &app,
                     [&](int) {
        if (controller.auditState() != QStringLiteral("complete")) {
            result = 6;
            app.quit();
            return;
        }
        controller.requestAiPlan();
    });
    QObject::connect(&controller, &RepairController::aiChanged, &app, [&] {
        if (controller.aiState() == QStringLiteral("error")
            || controller.aiState() == QStringLiteral("rejected")
            || controller.aiState() == QStringLiteral("denied")) {
            result = 7;
            app.quit();
            return;
        }
        if (!controller.readyToExecute() || executionStarted)
            return;
        if (controller.planSha256().size() != 64 || controller.confirmationPhrase().isEmpty()) {
            result = 8;
            app.quit();
            return;
        }
        executionStarted = true;
        controller.executeConfirmedPlan(controller.confirmationPhrase());
    });
    QObject::connect(&controller, &RepairController::executionChanged, &app, [&] {
        if (controller.executionState() == QStringLiteral("error")
            || controller.executionState() == QStringLiteral("complete_with_errors")) {
            result = 9;
            app.quit();
            return;
        }
        if (controller.executionState() != QStringLiteral("complete"))
            return;
        QFile marker(markerPath);
        const bool markerValid = marker.open(QIODevice::ReadOnly)
            && marker.readAll() == QByteArrayLiteral("MEOARCH_WRITE_ACTION_OK\n");
        const bool passed = markerValid && consents == 2 && providerRequests == 2
            && requestedModels == QStringList{QStringLiteral("proposal-test"),
                                              QStringLiteral("review-test")}
            && controller.executionLog().contains(
                QStringLiteral("All confirmed allowlisted actions finished."));
        result = passed ? 0 : 10;
        app.quit();
    });

    QTimer::singleShot(45000, &app, [&] {
        result = 11;
        app.quit();
    });

    controller.setAiSource(QStringLiteral("local"));
    controller.configureLocalAi(
        QStringLiteral("ollama"),
        QStringLiteral("http://127.0.0.1:%1").arg(server.serverPort()),
        QStringLiteral("proposal-test"), QStringLiteral("review-test"));
    controller.prepareGuidedCategory(QStringLiteral("network"));
    controller.setUserProblem(QStringLiteral("电脑无法连接网络"));
    controller.setGuidedAnswer(QStringLiteral("link_connected"), QStringLiteral("yes"));
    controller.setGuidedAnswer(QStringLiteral("any_site_opens"), QStringLiteral("no"));
    controller.setGuidedAnswer(QStringLiteral("other_devices_online"), QStringLiteral("yes"));
    controller.startQuickCheck(QStringLiteral("network"));

    app.exec();
    if (result == 0) {
        QTextStream(stdout)
            << "PASS: consent-bound local AI proposal, independent review, "
               "hash confirmation, and isolated typed write-action execution\n";
    } else {
        QTextStream(stderr)
            << "FAIL: repair AI flow smoke returned " << result
            << " (ai=" << controller.aiState()
            << " execution=" << controller.executionState()
            << " consents=" << consents
            << " requests=" << providerRequests << ")\n";
    }
    return result;
}

#include "ai-flow-smoke.moc"
