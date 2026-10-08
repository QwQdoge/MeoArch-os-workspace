#include "mcpgatewayadapter.h"
#include "policyengine.h"
#include "systemairouter.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QTextStream>

#include <memory>

namespace {

class FakeExecutor final : public MeoAi::CapabilityExecutor
{
public:
    QString id() const override { return QStringLiteral("test.executor"); }

    MeoAi::CapabilityResult execute(const MeoAi::Capability &capability,
                                    const MeoAi::CapabilityRequest &request) override
    {
        return {true, QStringLiteral("ok"), QStringLiteral("executed"), {}, capability.id,
                {{QStringLiteral("value"), request.input.value(QStringLiteral("value"))}}, true};
    }
};

MeoAi::Capability testCapability(const QString &id, const QString &effect,
                                 const QString &confirmation)
{
    MeoAi::Capability capability;
    capability.id = id;
    capability.owner = QStringLiteral("test.owner");
    capability.description = QStringLiteral("Contract test capability");
    capability.effect = effect;
    capability.privilege = QStringLiteral("user");
    capability.confirmation = confirmation;
    capability.executorId = QStringLiteral("test.executor");
    capability.inputSchema = {
        {QStringLiteral("type"), QStringLiteral("object")},
        {QStringLiteral("additionalProperties"), false},
        {QStringLiteral("required"), QJsonArray{QStringLiteral("value")}},
        {QStringLiteral("properties"), QJsonObject{
             {QStringLiteral("value"), QJsonObject{
                  {QStringLiteral("type"), QStringLiteral("integer")},
                  {QStringLiteral("minimum"), 0},
                  {QStringLiteral("maximum"), 100},
              }},
         }},
    };
    capability.executable = true;
    capability.mcpExposed = true;
    return capability;
}

int fail(int code, const QString &message)
{
    QTextStream(stderr) << "FAIL: " << message << '\n';
    return code;
}

} // namespace

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);

    MeoAi::SystemAiRouter router(false);
    QString error;
    if (!router.registerExecutor(std::make_unique<FakeExecutor>(), &error))
        return fail(1, error);

    if (!router.registry().find(QStringLiteral("settings.bluetooth.open")))
        return fail(2, QStringLiteral("built-in Settings capability missing"));

    MeoAi::Capability read = testCapability(QStringLiteral("test.echo.read"),
                                             QStringLiteral("read"),
                                             QStringLiteral("never"));
    if (!router.registry().registerCapability(read, &error))
        return fail(3, error);

    MeoAi::CapabilityRequest request;
    request.capabilityId = read.id;
    request.callerId = QStringLiteral("contract-test");
    request.input = {{QStringLiteral("value"), 42}};
    MeoAi::CapabilityResult result = router.invoke(request);
    if (!result.ok || !result.verificationPerformed)
        return fail(4, QStringLiteral("valid typed request did not execute"));

    request.input.insert(QStringLiteral("unexpected"), true);
    result = router.invoke(request);
    if (result.ok || result.code != QStringLiteral("invalid_input"))
        return fail(5, QStringLiteral("unexpected input was not rejected"));

    request.input = {{QStringLiteral("value"), 101}};
    result = router.invoke(request);
    if (result.ok || result.code != QStringLiteral("invalid_input"))
        return fail(6, QStringLiteral("out-of-range typed input was not rejected"));

    MeoAi::Capability write = testCapability(QStringLiteral("test.volume.set"),
                                              QStringLiteral("session"),
                                              QStringLiteral("state-change"));
    if (!router.registry().registerCapability(write, &error))
        return fail(7, error);

    request.capabilityId = write.id;
    request.input = {{QStringLiteral("value"), 30}};
    request.confirmationToken.clear();
    result = router.invoke(request);
    if (result.ok || result.status != QStringLiteral("confirmation_required"))
        return fail(8, QStringLiteral("state change bypassed confirmation"));

    const QString grant = router.issueConfirmationGrant(request, 60, &error);
    if (grant.isEmpty())
        return fail(9, QStringLiteral("confirmation grant was not issued: %1").arg(error));
    request.confirmationToken = grant;
    result = router.invoke(request);
    if (!result.ok)
        return fail(10, QStringLiteral("bound confirmation was not accepted"));

    result = router.invoke(request);
    if (result.ok || result.status != QStringLiteral("confirmation_required"))
        return fail(11, QStringLiteral("confirmation grant was not one-shot"));

    request.confirmationToken.clear();
    request.input = {{QStringLiteral("value"), 30}};
    const QString mismatchGrant = router.issueConfirmationGrant(request, 60, &error);
    if (mismatchGrant.isEmpty())
        return fail(12, QStringLiteral("second confirmation grant was not issued"));
    request.confirmationToken = mismatchGrant;
    request.input = {{QStringLiteral("value"), 31}};
    result = router.invoke(request);
    if (result.ok || result.status != QStringLiteral("confirmation_required"))
        return fail(13, QStringLiteral("confirmation grant was not bound to exact arguments"));

    MeoAi::McpGatewayAdapter gateway(&router.registry());
    const QString toolName = MeoAi::McpGatewayAdapter::toolNameForCapability(read.id);
    MeoAi::CapabilityRequest mcpRequest;
    if (!gateway.requestForTool(toolName, {{QStringLiteral("value"), 7}},
                                QStringLiteral("external-agent"), &mcpRequest, &error))
        return fail(14, error);
    if (mcpRequest.origin != QStringLiteral("mcp") || mcpRequest.capabilityId != read.id)
        return fail(15, QStringLiteral("MCP mapping escaped the capability identity"));

    if (gateway.requestForTool(QStringLiteral("shell_exec"), {},
                               QStringLiteral("external-agent"), &mcpRequest, &error))
        return fail(16, QStringLiteral("unregistered MCP tool was accepted"));

    request.confirmationToken.clear();
    request.capabilityId = QStringLiteral("desktop.audio.setVolume");
    request.input = {{QStringLiteral("percent"), 30}};
    result = router.invoke(request);
    if (result.ok || result.code != QStringLiteral("capability_unavailable"))
        return fail(17, QStringLiteral("unimplemented system adapter was treated as executable"));

    const MeoAi::Capability *terminal = router.registry().find(QStringLiteral("terminal.workspace.run"));
    if (!terminal || !terminal->executable || terminal->mcpExposed
        || terminal->executorId != QStringLiteral("terminal.workspace"))
        return fail(18, QStringLiteral("terminal capability contract is incorrect"));

    MeoAi::CapabilityRequest terminalRequest;
    terminalRequest.capabilityId = terminal->id;
    terminalRequest.callerId = QStringLiteral("meo-ai");
    terminalRequest.input = {{QStringLiteral("command"), QStringLiteral("printf hello")}};
    MeoAi::PolicyDecision terminalDecision = MeoAi::PolicyEngine().evaluate(*terminal,
                                                                            terminalRequest,
                                                                            true);
    if (terminalDecision.allowed || terminalDecision.code != QStringLiteral("permission_required"))
        return fail(19, QStringLiteral("terminal executed without workspace permission"));

    terminalRequest.grantedPermissions = {QStringLiteral("terminal.workspace")};
    terminalDecision = MeoAi::PolicyEngine().evaluate(*terminal, terminalRequest, true);
    if (!terminalDecision.allowed)
        return fail(20, QStringLiteral("authorized sandboxed terminal request was rejected"));

    const QString terminalTool = MeoAi::McpGatewayAdapter::toolNameForCapability(terminal->id);
    if (gateway.requestForTool(terminalTool, terminalRequest.input,
                               QStringLiteral("external-agent"), &mcpRequest, &error))
        return fail(21, QStringLiteral("terminal capability was exposed through MCP"));

    QTextStream(stdout) << "PASS: typed routing, bound confirmation, terminal permission and MCP boundaries\n";
    return 0;
}
