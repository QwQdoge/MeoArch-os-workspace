#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    // 启用高分屏缩放支持 (Qt6 默认开启，但加上以防万一)
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 让 QML 引擎能够找到 MeoUI 模块
    engine.addImportPath(app.applicationDirPath() + "/MeoUI");
    engine.addImportPath(app.applicationDirPath());

    const QUrl url(QStringLiteral("qrc:/MeoUI/showcase/MeoShowcase.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [&](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
