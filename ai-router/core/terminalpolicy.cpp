#include "terminalpolicy.h"

#include <QRegularExpression>
#include <QVector>

namespace MeoAi {
namespace {

struct Rule final
{
    const char *id;
    const char *reason;
    const char *pattern;
};

const QVector<Rule> &elevatedRules()
{
    static const QVector<Rule> rules{
        {"privilege", "The command requests elevated privileges.",
         R"((^|[;&|]\s*|\s)(sudo|doas|pkexec|su)(\s|$))"},
        {"packages", "The command can change installed software or package trust state.",
         R"((^|[;&|]\s*|\s)(pacman|yay|paru|pamac|apt|apt-get|dnf|yum|zypper)(\s|$))"},
        {"disk", "The command can modify disks, filesystems, encryption, or volume metadata.",
         R"(\b(dd|mkfs(?:\.[a-z0-9_-]+)?|fdisk|cfdisk|sfdisk|parted|wipefs|cryptsetup|lvremove|vgremove|pvremove)\b)"},
        {"delete", "The command deletes or irreversibly truncates data.",
         R"((^|[;&|]\s*|\s)(rm|rmdir|shred|truncate)(\s|$))"},
        {"service", "The command changes service or system-manager state.",
         R"(\bsystemctl\s+(start|stop|restart|try-restart|reload|enable|disable|reenable|mask|unmask|daemon-reload|edit|set-property)\b)"},
        {"power", "The command can end the current session or power-cycle the machine.",
         R"((^|[;&|]\s*|\s)(reboot|shutdown|poweroff|halt)(\s|$))"},
        {"permissions", "The command changes file ownership, permissions, ACLs, or attributes.",
         R"((^|[;&|]\s*|\s)(chmod|chown|chgrp|setfacl|chattr)(\s|$))"},
        {"process", "The command sends signals to other processes.",
         R"((^|[;&|]\s*|\s)(kill|killall|pkill)(\s|$))"},
        {"network", "The command can change firewall, routes, or persistent network configuration.",
         R"(\b(iptables|ip6tables|nft|ufw|firewall-cmd)\b|\bnmcli\s+(connection|con)\s+(delete|modify|up|down)\b|\bip\s+(route|rule|link|address|addr)\s+(add|del|delete|replace|set)\b)"},
        {"boot", "The command can change boot or kernel state.",
         R"(\b(bootctl|grub-install|grub-mkconfig|mkinitcpio|dracut|modprobe|rmmod|insmod)\b)"},
        {"system-write", "The command appears to write into a system-owned path.",
         R"((>|>>|\btee\b|\binstall\b|\bcp\b|\bmv\b)[^\n;&|]*(/(etc|usr|boot|var|opt|root|run|dev|sys|proc))(?:/|\b))"},
        {"remote-pipe", "Downloaded content is piped directly into a shell.",
         R"(\b(curl|wget)\b[^\n|;&]*\|\s*(sudo\s+|doas\s+|pkexec\s+)?(sh|bash|zsh|fish)\b)"},
    };
    return rules;
}

} // namespace

TerminalRiskDecision TerminalPolicy::classify(const QString &command)
{
    TerminalRiskDecision decision;
    const QString normalized = command.trimmed();
    if (normalized.isEmpty())
        return decision;

    for (const Rule &rule : elevatedRules()) {
        const QRegularExpression expression(QString::fromLatin1(rule.pattern),
                                            QRegularExpression::CaseInsensitiveOption);
        if (expression.match(normalized).hasMatch()) {
            decision.risk = TerminalRisk::Elevated;
            decision.matchedRules.append(QString::fromLatin1(rule.id));
            if (decision.reason.isEmpty())
                decision.reason = QString::fromLatin1(rule.reason);
        }
    }
    return decision;
}

QString TerminalPolicy::riskName(TerminalRisk risk)
{
    return risk == TerminalRisk::Elevated ? QStringLiteral("elevated")
                                          : QStringLiteral("normal");
}

} // namespace MeoAi
