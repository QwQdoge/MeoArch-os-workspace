#pragma once

#include "systemairouter.h"

namespace MeoAi {

class TerminalWorkspaceExecutor final : public CapabilityExecutor
{
public:
    QString id() const override { return QStringLiteral("terminal.workspace"); }
    CapabilityResult execute(const Capability &capability,
                             const CapabilityRequest &request) override;
};

} // namespace MeoAi
