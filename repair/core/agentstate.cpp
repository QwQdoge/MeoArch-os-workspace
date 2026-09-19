#include "agentstate.h"

#include <QSet>

namespace MeoRepair {

QString AgentStateMachine::stateName() const
{
    switch (m_state) {
    case State::Init: return QStringLiteral("INIT");
    case State::Classify: return QStringLiteral("CLASSIFY");
    case State::Collect: return QStringLiteral("COLLECT");
    case State::Ask: return QStringLiteral("ASK");
    case State::WaitUser: return QStringLiteral("WAIT_USER");
    case State::CollectMore: return QStringLiteral("COLLECT_MORE");
    case State::BuildPlan: return QStringLiteral("BUILD_PLAN");
    case State::Review: return QStringLiteral("REVIEW");
    case State::WaitConfirm: return QStringLiteral("WAIT_CONFIRM");
    case State::Authorize: return QStringLiteral("AUTHORIZE");
    case State::Execute: return QStringLiteral("EXECUTE");
    case State::Verify: return QStringLiteral("VERIFY");
    case State::Done: return QStringLiteral("DONE");
    case State::Cancelled: return QStringLiteral("CANCELLED");
    case State::Failed: return QStringLiteral("FAILED");
    case State::Handoff: return QStringLiteral("HANDOFF");
    }
    return QStringLiteral("FAILED");
}

bool AgentStateMachine::transition(State next)
{
    if (next == State::Cancelled || next == State::Failed) {
        m_state = next;
        return true;
    }
    bool allowed = false;
    switch (m_state) {
    case State::Init: allowed = next == State::Classify; break;
    case State::Classify: allowed = next == State::Collect || next == State::Ask; break;
    case State::Collect: allowed = next == State::Ask || next == State::BuildPlan; break;
    case State::Ask: allowed = next == State::WaitUser; break;
    case State::WaitUser: allowed = next == State::CollectMore; break;
    case State::CollectMore: allowed = next == State::Ask || next == State::BuildPlan; break;
    case State::BuildPlan: allowed = next == State::Review || next == State::Handoff; break;
    case State::Review: allowed = next == State::WaitConfirm || next == State::Handoff; break;
    case State::WaitConfirm: allowed = next == State::Authorize; break;
    case State::Authorize: allowed = next == State::Execute; break;
    case State::Execute: allowed = next == State::Verify; break;
    case State::Verify: allowed = next == State::Done || next == State::Handoff; break;
    case State::Done:
    case State::Cancelled:
    case State::Failed:
    case State::Handoff:
        break;
    }
    if (allowed)
        m_state = next;
    return allowed;
}

} // namespace MeoRepair
