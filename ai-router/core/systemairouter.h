#pragma once

#include "capabilityregistry.h"

#include <QDateTime>
#include <QHash>
#include <QJsonObject>
#include <QString>
#include <QStringList>

#include <memory>
#include <vector>

namespace MeoAi {

struct CapabilityRequest final
{
    QString capabilityId;
    QJsonObject input;
    QString callerId;
    QString origin = QStringLiteral("native");
    QStringList grantedPermissions;
    QString confirmationToken;
};

struct CapabilityResult final
{
    bool ok = false;
    QString status;
    QString code;
    QString message;
    QString capabilityId;
    QJsonObject data;
    bool verificationPerformed = false;

    QJsonObject toJson() const;
};

class CapabilityExecutor
{
public:
    virtual ~CapabilityExecutor() = default;
    virtual QString id() const = 0;
    virtual CapabilityResult execute(const Capability &capability,
                                     const CapabilityRequest &request) = 0;
};

class SystemAiRouter final
{
public:
    explicit SystemAiRouter(bool installDefaultExecutors = true);

    CapabilityRegistry &registry() { return m_registry; }
    const CapabilityRegistry &registry() const { return m_registry; }

    bool registerExecutor(std::unique_ptr<CapabilityExecutor> executor,
                          QString *error = nullptr);

    // The UI calls this only after a real user confirmation. The returned
    // token is one-shot, short-lived, and bound to capability/input/caller/origin.
    QString issueConfirmationGrant(const CapabilityRequest &request,
                                   int ttlSeconds = 60,
                                   QString *error = nullptr);
    CapabilityResult invoke(const CapabilityRequest &request);

private:
    struct ConfirmationGrant final
    {
        QString binding;
        QDateTime expiresAt;
    };

    CapabilityExecutor *executorFor(const QString &id) const;
    QString requestBinding(const CapabilityRequest &request) const;
    bool consumeMatchingConfirmation(const CapabilityRequest &request);
    void purgeExpiredConfirmations();

    CapabilityRegistry m_registry;
    std::vector<std::unique_ptr<CapabilityExecutor>> m_executors;
    QHash<QString, ConfirmationGrant> m_confirmationGrants;
};

} // namespace MeoAi
