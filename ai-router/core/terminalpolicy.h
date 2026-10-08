#pragma once

#include <QString>
#include <QStringList>

namespace MeoAi {

enum class TerminalRisk {
    Normal,
    Elevated,
};

struct TerminalRiskDecision final
{
    TerminalRisk risk = TerminalRisk::Normal;
    QString reason;
    QStringList matchedRules;
};

class TerminalPolicy final
{
public:
    static TerminalRiskDecision classify(const QString &command);
    static QString riskName(TerminalRisk risk);
};

} // namespace MeoAi
