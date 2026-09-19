#pragma once

#include <QString>

namespace MeoRepair {

class AgentStateMachine final
{
public:
    enum class State {
        Init,
        Classify,
        Collect,
        Ask,
        WaitUser,
        CollectMore,
        BuildPlan,
        Review,
        WaitConfirm,
        Authorize,
        Execute,
        Verify,
        Done,
        Cancelled,
        Failed,
        Handoff
    };

    State state() const { return m_state; }
    QString stateName() const;
    void reset() { m_state = State::Init; }
    bool transition(State next);

private:
    State m_state = State::Init;
};

} // namespace MeoRepair
