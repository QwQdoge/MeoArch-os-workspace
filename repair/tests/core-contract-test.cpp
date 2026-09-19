#include "agentstate.h"
#include "capabilityregistry.h"

#include <QCoreApplication>
#include <QSet>
#include <QTextStream>

int main(int argc, char **argv)
{
    QCoreApplication application(argc, argv);
    using State = MeoRepair::AgentStateMachine::State;

    MeoRepair::AgentStateMachine state;
    const bool normalFlow = state.transition(State::Classify)
        && state.transition(State::Collect)
        && state.transition(State::BuildPlan)
        && state.transition(State::Review)
        && state.transition(State::WaitConfirm)
        && state.transition(State::Authorize)
        && state.transition(State::Execute)
        && state.transition(State::Verify)
        && state.transition(State::Done);
    if (!normalFlow || state.stateName() != QStringLiteral("DONE")) {
        QTextStream(stderr) << "FAIL: authoritative state sequence rejected\n";
        return 1;
    }

    state.reset();
    if (!state.transition(State::Classify) || !state.transition(State::Collect)
        || state.transition(State::Execute)) {
        QTextStream(stderr) << "FAIL: execution bypass was not rejected\n";
        return 2;
    }

    QSet<QString> ids;
    for (const MeoRepair::Capability &capability : MeoRepair::CapabilityRegistry::all()) {
        if (capability.id.isEmpty() || ids.contains(capability.id)
            || !QSet<QString>{QStringLiteral("read"), QStringLiteral("session"),
                              QStringLiteral("persistent"), QStringLiteral("destructive")}
                    .contains(capability.effect)
            || !QSet<QString>{QStringLiteral("user"), QStringLiteral("system")}
                    .contains(capability.privilege)
            || !QSet<QString>{QStringLiteral("automatic"), QStringLiteral("manual"),
                              QStringLiteral("none")}
                    .contains(capability.reversibility)
            || !QSet<QString>{QStringLiteral("local"), QStringLiteral("minimal"),
                              QStringLiteral("enhanced"), QStringLiteral("never")}
                    .contains(capability.exportability)
            || (capability.effect == QStringLiteral("destructive") && capability.executable)) {
            QTextStream(stderr) << "FAIL: invalid capability registry entry\n";
            return 3;
        }
        ids.insert(capability.id);
    }

    QTextStream(stdout) << "PASS: state authority and capability policy contracts\n";
    return 0;
}
