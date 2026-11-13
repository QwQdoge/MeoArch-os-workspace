#pragma once

#include "systemairouter.h"

namespace MeoAi {

// Installer-facing capabilities for the Live environment.
//
// The executor never touches disks, accounts or the installer process. It can
// only (a) write a bounded, allow-listed *proposal* file into the Live user's
// runtime directory and (b) read the tail of the installer log. The root
// installer treats the proposal as untrusted input: it re-validates every field
// and applies nothing until the person confirms it on screen.
class InstallerProposalExecutor final : public CapabilityExecutor
{
public:
    QString id() const override { return QStringLiteral("installer.proposal"); }
    CapabilityResult execute(const Capability &capability,
                             const CapabilityRequest &request) override;

    // Exposed for tests and for the installer's own validation contract.
    // Returns a normalized {section: {key: value}} object or an empty object
    // with *error set.
    static QJsonObject normalizeProposal(const QJsonObject &input, QString *error);
    static QString proposalPath();
    static bool liveEnvironment();
};

} // namespace MeoAi
