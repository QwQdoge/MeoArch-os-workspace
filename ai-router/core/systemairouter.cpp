#include "systemairouter.h"

#include "policyengine.h"
#include "settingsdeeplinkexecutor.h"

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

CapabilityResult SystemAiRouter::invoke(const CapabilityRequest &request)
{
    const Capability *capability = m_registry.find(request.capabilityId);
    if (!capability) {
        return {false, QStringLiteral("rejected"), QStringLiteral("unknown_capability"),
                QStringLiteral("The requested capability is not registered."),
                request.capabilityId, {}, false};
    }

    const PolicyDecision decision = PolicyEngine().evaluate(*capability, request);
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
