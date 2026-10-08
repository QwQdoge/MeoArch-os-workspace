#pragma once

#include "capabilityregistry.h"
#include "systemairouter.h"

#include <QString>

namespace MeoAi {

struct PolicyDecision final
{
    bool allowed = false;
    bool confirmationRequired = false;
    QString code;
    QString message;
};

class PolicyEngine final
{
public:
    PolicyDecision evaluate(const Capability &capability,
                            const CapabilityRequest &request,
                            bool confirmationSatisfied = false) const;

    static bool requiresConfirmation(const Capability &capability);
    static bool validateInput(const QJsonObject &schema,
                              const QJsonObject &input,
                              QString *error = nullptr);
};

} // namespace MeoAi
