#pragma once

#include "capabilityregistry.h"

#include <QJsonObject>
#include <QString>

#include <memory>
#include <vector>

namespace MeoAi {

struct CapabilityRequest final
{
    QString capabilityId;
    QJsonObject input;
    QString callerId;
    QString origin = QStringLiteral("native");
    bool confirmed = false;
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
    CapabilityResult invoke(const CapabilityRequest &request);

private:
    CapabilityExecutor *executorFor(const QString &id) const;

    CapabilityRegistry m_registry;
    std::vector<std::unique_ptr<CapabilityExecutor>> m_executors;
};

} // namespace MeoAi
