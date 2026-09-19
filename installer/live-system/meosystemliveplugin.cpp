#include "systemstatehub.h"

#include <QQmlEngine>
#include <QQmlExtensionPlugin>
#include <qqml.h>

namespace
{
QObject *systemStateProvider(QQmlEngine *, QJSEngine *)
{
    auto *state = new SystemStateHub;
    QQmlEngine::setObjectOwnership(state, QQmlEngine::CppOwnership);
    return state;
}

class MeoSystemLivePlugin final : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(QByteArray(uri) == QByteArray("Meo.System"));
        qmlRegisterSingletonType<SystemStateHub>(uri, 1, 0, "SystemState",
                                                 systemStateProvider);
    }
};
}

#include "meosystemliveplugin.moc"
