#include "capabilityregistry.h"

#include <QRegularExpression>
#include <QSet>

namespace MeoAi {
namespace {

QJsonObject noArgumentsSchema()
{
    return {
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("additionalProperties"), false},
    };
}

QJsonObject volumeSchema()
{
    return {
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("additionalProperties"), false},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("percent")}},
        {QStringLiteral("properties"), QJsonObject{
             {QStringLiteral("percent"), QJsonObject{
                  {QStringLiteral("type"), QStringLiteral("integer")},
                  {QStringLiteral("minimum"), 0},
                  {QStringLiteral("maximum"), 100},
              }},
         }},
    };
}

QJsonObject fileSearchSchema()
{
    return {
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("additionalProperties"), false},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("query")}},
        {QStringLiteral("properties"), QJsonObject{
             {QStringLiteral("query"), QJsonObject{
                  {QStringLiteral("type"), QStringLiteral("string")},
                  {QStringLiteral("minLength"), 1},
                  {QStringLiteral("maxLength"), 256},
              }},
         }},
    };
}

QJsonObject terminalWorkspaceSchema()
{
    return {
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("additionalProperties"), false},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("command")}},
        {QStringLiteral("properties"), QJsonObject{
             {QStringLiteral("command"), QJsonObject{
                  {QStringLiteral("type"), QStringLiteral("string")},
                  {QStringLiteral("minLength"), 1},
                  {QStringLiteral("maxLength"), 4096},
              }},
             {QStringLiteral("cwd"), QJsonObject{
                  {QStringLiteral("type"), QStringLiteral("string")},
                  {QStringLiteral("maxLength"), 512},
              }},
             {QStringLiteral("timeoutSeconds"), QJsonObject{
                  {QStringLiteral("type"), QStringLiteral("integer")},
                  {QStringLiteral("minimum"), 1},
                  {QStringLiteral("maximum"), 120},
              }},
         }},
    };
}

Capability settingsOpenCapability(const QString &id,
                                  const QString &route,
                                  const QString &description)
{
    Capability capability;
    capability.id = id;
    capability.owner = QStringLiteral("org.meo.settings");
    capability.description = description;
    capability.effect = QStringLiteral("open");
    capability.privilege = QStringLiteral("user");
    capability.confirmation = QStringLiteral("never");
    capability.executorId = QStringLiteral("settings.deep-link");
    capability.inputSchema = noArgumentsSchema();
    capability.fixedArguments = {{QStringLiteral("route"), route}};
    capability.executable = true;
    capability.mcpExposed = true;
    return capability;
}

Capability terminalWorkspaceCapability()
{
    Capability capability;
    capability.id = QStringLiteral("terminal.workspace.run");
    capability.owner = QStringLiteral("org.meo.ai-router");
    capability.description = QStringLiteral(
        "Run a user-level shell command inside the explicitly granted workspace sandbox.");
    capability.effect = QStringLiteral("persistent");
    capability.privilege = QStringLiteral("user");
    capability.confirmation = QStringLiteral("never");
    capability.executorId = QStringLiteral("terminal.workspace");
    capability.inputSchema = terminalWorkspaceSchema();
    capability.requiredPermissions = {QStringLiteral("terminal.workspace")};
    capability.executable = true;
    capability.mcpExposed = false;
    return capability;
}

Capability unavailableCapability(const QString &id,
                                 const QString &owner,
                                 const QString &description,
                                 const QString &effect,
                                 const QJsonObject &inputSchema)
{
    Capability capability;
    capability.id = id;
    capability.owner = owner;
    capability.description = description;
    capability.effect = effect;
    capability.privilege = QStringLiteral("user");
    capability.confirmation = effect == QStringLiteral("read")
        ? QStringLiteral("never")
        : QStringLiteral("state-change");
    capability.inputSchema = inputSchema;
    capability.executable = false;
    capability.mcpExposed = false;
    return capability;
}

} // namespace

CapabilityRegistry::CapabilityRegistry()
{
    m_capabilities = {
        settingsOpenCapability(QStringLiteral("settings.wifi.open"),
                               QStringLiteral("wifi"),
                               QStringLiteral("Open the native Wi-Fi settings page.")),
        settingsOpenCapability(QStringLiteral("settings.bluetooth.open"),
                               QStringLiteral("bluetooth"),
                               QStringLiteral("Open the native Bluetooth settings page.")),
        settingsOpenCapability(QStringLiteral("settings.audio.open"),
                               QStringLiteral("sound"),
                               QStringLiteral("Open the native sound settings page.")),
        settingsOpenCapability(QStringLiteral("settings.display.open"),
                               QStringLiteral("display"),
                               QStringLiteral("Open the native display settings page.")),
        settingsOpenCapability(QStringLiteral("settings.appearance.open"),
                               QStringLiteral("appearance"),
                               QStringLiteral("Open the native appearance settings page.")),
        terminalWorkspaceCapability(),
        unavailableCapability(QStringLiteral("network.status.read"),
                              QStringLiteral("meo-system-service"),
                              QStringLiteral("Read a structured network summary."),
                              QStringLiteral("read"), noArgumentsSchema()),
        unavailableCapability(QStringLiteral("bluetooth.status.read"),
                              QStringLiteral("meo-system-service"),
                              QStringLiteral("Read adapter and connection status."),
                              QStringLiteral("read"), noArgumentsSchema()),
        unavailableCapability(QStringLiteral("system.performance.summary"),
                              QStringLiteral("meo-system-monitor"),
                              QStringLiteral("Read a bounded performance summary."),
                              QStringLiteral("read"), noArgumentsSchema()),
        unavailableCapability(QStringLiteral("file.search"),
                              QStringLiteral("meo-file-search"),
                              QStringLiteral("Search through the owning file/search service."),
                              QStringLiteral("read"), fileSearchSchema()),
        unavailableCapability(QStringLiteral("desktop.audio.setVolume"),
                              QStringLiteral("meo-system-service"),
                              QStringLiteral("Set the default output volume through the audio authority."),
                              QStringLiteral("session"), volumeSchema()),
        unavailableCapability(QStringLiteral("application.launch"),
                              QStringLiteral("meo-app-service"),
                              QStringLiteral("Launch a registered desktop application by stable app id."),
                              QStringLiteral("open"), QJsonObject{
                                  {QStringLiteral("type"), QStringLiteral("object")},
                                  {QStringLiteral("additionalProperties"), false},
                                  {QStringLiteral("required"), QJsonArray{QStringLiteral("appId")}},
                                  {QStringLiteral("properties"), QJsonObject{
                                       {QStringLiteral("appId"), QJsonObject{
                                            {QStringLiteral("type"), QStringLiteral("string")},
                                            {QStringLiteral("minLength"), 1},
                                            {QStringLiteral("maxLength"), 256},
                                        }},
                                   }},
                              }),
    };
}

QString CapabilityRegistry::policyVersion()
{
    return QStringLiteral("org.meo.ai-router-policy/2026.10.08.4");
}

const Capability *CapabilityRegistry::find(const QString &id) const
{
    for (const Capability &capability : m_capabilities) {
        if (capability.id == id)
            return &capability;
    }
    return nullptr;
}

bool CapabilityRegistry::registerCapability(const Capability &capability, QString *error)
{
    if (!validateDescriptor(capability, error))
        return false;
    if (find(capability.id)) {
        if (error)
            *error = QStringLiteral("capability id is already registered");
        return false;
    }
    m_capabilities.append(capability);
    return true;
}

bool CapabilityRegistry::validateDescriptor(const Capability &capability, QString *error)
{
    static const QRegularExpression idPattern(
        QStringLiteral("^[a-z][a-z0-9]*(?:[._-][A-Za-z0-9]+)*$"));
    static const QSet<QString> effects{
        QStringLiteral("read"), QStringLiteral("open"), QStringLiteral("session"),
        QStringLiteral("persistent"), QStringLiteral("destructive")};
    static const QSet<QString> privileges{
        QStringLiteral("user"), QStringLiteral("system")};
    static const QSet<QString> confirmations{
        QStringLiteral("never"), QStringLiteral("state-change"), QStringLiteral("always")};

    auto fail = [error](const QString &message) {
        if (error)
            *error = message;
        return false;
    };

    if (!idPattern.match(capability.id).hasMatch())
        return fail(QStringLiteral("invalid capability id"));
    if (capability.owner.trimmed().isEmpty())
        return fail(QStringLiteral("capability owner is required"));
    if (!effects.contains(capability.effect))
        return fail(QStringLiteral("invalid capability effect"));
    if (!privileges.contains(capability.privilege))
        return fail(QStringLiteral("invalid capability privilege"));
    if (!confirmations.contains(capability.confirmation))
        return fail(QStringLiteral("invalid confirmation policy"));
    if (capability.inputSchema.value(QStringLiteral("type")).toString() != QStringLiteral("object"))
        return fail(QStringLiteral("capability input schema must describe an object"));
    if (capability.executable && capability.executorId.trimmed().isEmpty())
        return fail(QStringLiteral("executable capability needs an executor"));
    if (capability.effect == QStringLiteral("destructive") && capability.confirmation != QStringLiteral("always"))
        return fail(QStringLiteral("destructive capability must always require confirmation"));
    if (capability.mcpExposed && !capability.executable)
        return fail(QStringLiteral("non-executable capability cannot be exposed through MCP"));
    return true;
}

} // namespace MeoAi
