#include "systemairouter.h"

#include "policyengine.h"
#include "settingsdeeplinkexecutor.h"

#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonDocument>
#include <QUuid>

#include <algorithm>

namespace MeoAi {

QJsonObject CapabilityResult::toJson() const
{
    return {
        {QStringLiteral("ok"), ok},
        {QStringLiteral("status"), status},
        {QStringLiteral("code"), code},
        {QStringLiteral("message"), message},
        {QStringLiteral("capabilityId"), capabilityId},
        {QStringLiteral("data"), data},
        {QStringLiteral("verificationPerformed"), verificationPerformed},
    };
}

SystemAiRouter::SystemAiRouter(bool installDefaultExecutors)
{
    if (installDefaultExecutors)
        registerExecutor(std::make_unique<SettingsDeepLinkExecutor>());
}

bool SystemAiRouter::registerExecutor(std::unique_ptr<CapabilityExecutor> executor,
                                      QString *error)
{
    if (!executor || executor->id().trimmed().isEmpty()) {
        if (error)
            *error = QStringLiteral("executor id is required");
        return false;
    }
    if (executorFor(executor->id())) {
        if (error)
            *error = QStringLiteral("executor id is already registered");
        return false;
    }
    m_executors.push_back(std::move(executor));
    return true;
}

CapabilityExecutor *SystemAiRouter::executorFor(const QString &id) const
{
    for (const auto &executor : m_executors) {
        if (executor && executor->id() == id)
            return executor.get();
    }
    return nullptr;
}

QString SystemAiRouter::requestBinding(const CapabilityRequest &request) const
{
    QStringList permissions = request.grantedPermissions;
    permissions.sort(Qt::CaseSensitive);

    QJsonArray permissionArray;
    for (const QString &permission : permissions)
        permissionArray.append(permission);

    const QJsonObject bindingObject{
        {QStringLiteral("capabilityId"), request.capabilityId},
        {QStringLiteral("input"), request.input},
        {QStringLiteral("callerId"), request.callerId},
        {QStringLiteral("origin"), request.origin},
        {QStringLiteral("permissions"), permissionArray},
        {QStringLiteral("policyVersion"), CapabilityRegistry::policyVersion()},
    };
    return QString::fromLatin1(QCryptographicHash::hash(
        QJsonDocument(bindingObject).toJson(QJsonDocument::Compact),
        QCryptographicHash::Sha256).toHex());
}

void SystemAiRouter::purgeExpiredConfirmations()
{
    const QDateTime now = QDateTime::currentDateTimeUtc();
    for (auto it = m_confirmationGrants.begin(); it != m_confirmationGrants.end();) {
        if (it->expiresAt <= now)
            it = m_confirmationGrants.erase(it);
        else
            ++it;
    }
}

QString SystemAiRouter::issueConfirmationGrant(const CapabilityRequest &request,
                                               int ttlSeconds,
                                               QString *error)
{
    purgeExpiredConfirmations();
    const Capability *capability = m_registry.find(request.capabilityId);
    if (!capability) {
        if (error)
            *error = QStringLiteral("unknown capability");
        return {};
    }
    if (!PolicyEngine::requiresConfirmation(*capability)) {
        if (error)
            *error = QStringLiteral("capability does not require confirmation");
        return {};
    }

    const PolicyDecision preflight = PolicyEngine().evaluate(*capability, request, true);
    if (!preflight.allowed) {
        if (error)
            *error = preflight.message;
        return {};
    }

    ttlSeconds = std::clamp(ttlSeconds, 1, 300);
    const QString token = QUuid::createUuid().toString(QUuid::WithoutBraces);
    m_confirmationGrants.insert(token, {
        requestBinding(request),
        QDateTime::currentDateTimeUtc().addSecs(ttlSeconds),
    });
    return token;
}

bool SystemAiRouter::consumeMatchingConfirmation(const CapabilityRequest &request)
{
    purgeExpiredConfirmations();
    if (request.confirmationToken.isEmpty())
        return false;

    auto it = m_confirmationGrants.find(request.confirmationToken);
    if (it == m_confirmationGrants.end())
        return false;

    const QString expectedBinding = it->binding;
    m_confirmationGrants.erase(it);
    return expectedBinding == requestBinding(request);
}

CapabilityResult SystemAiRouter::invoke(const CapabilityRequest &request)
{
    const Capability *capability = m_registry.find(request.capabilityId);
    if (!capability) {
        return {false, QStringLiteral("rejected"), QStringLiteral("unknown_capability"),
                QStringLiteral("The requested capability is not registered."),
                request.capabilityId, {}, false};
    }

    const bool confirmationSatisfied = !PolicyEngine::requiresConfirmation(*capability)
        || consumeMatchingConfirmation(request);
    const PolicyDecision decision = PolicyEngine().evaluate(*capability, request,
                                                             confirmationSatisfied);
    if (!decision.allowed) {
        return {false,
                decision.confirmationRequired ? QStringLiteral("confirmation_required")
                                              : QStringLiteral("rejected"),
                decision.code, decision.message, capability->id, {}, false};
    }

    CapabilityExecutor *executor = executorFor(capability->executorId);
    if (!executor) {
        return {false, QStringLiteral("unavailable"), QStringLiteral("executor_unavailable"),
                QStringLiteral("The owning capability executor is not available."),
                capability->id, {}, false};
    }

    CapabilityResult result = executor->execute(*capability, request);
    result.capabilityId = capability->id;
    return result;
}

} // namespace MeoAi
