#include "policyengine.h"

#include <QJsonArray>
#include <QJsonValue>

namespace MeoAi {
namespace {

bool validateValue(const QJsonObject &schema, const QJsonValue &value, QString *error)
{
    auto fail = [error](const QString &message) {
        if (error)
            *error = message;
        return false;
    };

    const QString type = schema.value(QStringLiteral("type")).toString();
    if (type == QStringLiteral("string")) {
        if (!value.isString())
            return fail(QStringLiteral("expected string"));
        const QString text = value.toString();
        const int minLength = schema.value(QStringLiteral("minLength")).toInt(-1);
        const int maxLength = schema.value(QStringLiteral("maxLength")).toInt(-1);
        if (minLength >= 0 && text.size() < minLength)
            return fail(QStringLiteral("string is shorter than minLength"));
        if (maxLength >= 0 && text.size() > maxLength)
            return fail(QStringLiteral("string is longer than maxLength"));
        const QJsonArray allowed = schema.value(QStringLiteral("enum")).toArray();
        if (!allowed.isEmpty() && !allowed.contains(value))
            return fail(QStringLiteral("string is not in the allowlist"));
        return true;
    }

    if (type == QStringLiteral("integer")) {
        const double number = value.toDouble(std::numeric_limits<double>::quiet_NaN());
        if (!value.isDouble() || !std::isfinite(number) || std::floor(number) != number)
            return fail(QStringLiteral("expected integer"));
        if (schema.contains(QStringLiteral("minimum"))
            && number < schema.value(QStringLiteral("minimum")).toDouble())
            return fail(QStringLiteral("integer is below minimum"));
        if (schema.contains(QStringLiteral("maximum"))
            && number > schema.value(QStringLiteral("maximum")).toDouble())
            return fail(QStringLiteral("integer is above maximum"));
        return true;
    }

    if (type == QStringLiteral("boolean")) {
        if (!value.isBool())
            return fail(QStringLiteral("expected boolean"));
        return true;
    }

    return fail(QStringLiteral("unsupported property schema type"));
}

} // namespace

bool PolicyEngine::requiresConfirmation(const Capability &capability)
{
    const bool stateChanging = capability.effect == QStringLiteral("session")
        || capability.effect == QStringLiteral("persistent")
        || capability.effect == QStringLiteral("destructive");
    return capability.confirmation == QStringLiteral("always")
        || (capability.confirmation == QStringLiteral("state-change") && stateChanging);
}

PolicyDecision PolicyEngine::evaluate(const Capability &capability,
                                      const CapabilityRequest &request,
                                      bool confirmationSatisfied) const
{
    if (!capability.executable) {
        return {false, false, QStringLiteral("capability_unavailable"),
                QStringLiteral("The owning component has not exposed an executable typed adapter yet.")};
    }
    if (request.callerId.trimmed().isEmpty()) {
        return {false, false, QStringLiteral("caller_required"),
                QStringLiteral("Every capability invocation must be caller-bound.")};
    }
    if (request.origin != QStringLiteral("native") && request.origin != QStringLiteral("mcp")) {
        return {false, false, QStringLiteral("invalid_origin"),
                QStringLiteral("The request origin is not supported.")};
    }
    if (request.origin == QStringLiteral("mcp") && !capability.mcpExposed) {
        return {false, false, QStringLiteral("mcp_not_exposed"),
                QStringLiteral("This capability is not exposed through the MCP gateway.")};
    }

    QString inputError;
    if (!validateInput(capability.inputSchema, request.input, &inputError)) {
        return {false, false, QStringLiteral("invalid_input"), inputError};
    }

    for (const QString &permission : capability.requiredPermissions) {
        if (!request.grantedPermissions.contains(permission)) {
            return {false, false, QStringLiteral("permission_required"),
                    QStringLiteral("Required permission is missing: %1").arg(permission)};
        }
    }

    if (requiresConfirmation(capability) && !confirmationSatisfied) {
        return {false, true, QStringLiteral("confirmation_required"),
                QStringLiteral("User confirmation is required for this exact capability request.")};
    }

    return {true, false, QStringLiteral("allowed"), {}};
}

bool PolicyEngine::validateInput(const QJsonObject &schema,
                                 const QJsonObject &input,
                                 QString *error)
{
    auto fail = [error](const QString &message) {
        if (error)
            *error = message;
        return false;
    };

    if (schema.value(QStringLiteral("type")).toString() != QStringLiteral("object"))
        return fail(QStringLiteral("capability schema is not an object schema"));

    const QJsonObject properties = schema.value(QStringLiteral("properties")).toObject();
    const QJsonArray required = schema.value(QStringLiteral("required")).toArray();
    for (const QJsonValue &item : required) {
        const QString key = item.toString();
        if (key.isEmpty() || !input.contains(key))
            return fail(QStringLiteral("missing required field: %1").arg(key));
    }

    const bool additionalProperties = schema.value(QStringLiteral("additionalProperties")).toBool(true);
    for (auto it = input.constBegin(); it != input.constEnd(); ++it) {
        if (!properties.contains(it.key())) {
            if (!additionalProperties)
                return fail(QStringLiteral("unexpected field: %1").arg(it.key()));
            continue;
        }
        QString valueError;
        if (!validateValue(properties.value(it.key()).toObject(), it.value(), &valueError))
            return fail(QStringLiteral("%1: %2").arg(it.key(), valueError));
    }

    return true;
}

} // namespace MeoAi
