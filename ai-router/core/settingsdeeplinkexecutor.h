#pragma once

#include "systemairouter.h"

namespace MeoAi {

class SettingsDeepLinkExecutor final : public CapabilityExecutor
{
public:
    QString id() const override { return QStringLiteral("settings.deep-link"); }
    CapabilityResult execute(const Capability &capability,
                             const CapabilityRequest &request) override;
};

} // namespace MeoAi
