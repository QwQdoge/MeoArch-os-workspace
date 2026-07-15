#include <QGuiApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QIODevice>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QResource>
#include <QQuickWindow>
#include <QTimer>
#include <QObject>
#include <QTextStream>
#include <QUrl>
#include <QWindow>
#include <Qt>

namespace {
QFile *gLogFile = nullptr;

void messageHandler(QtMsgType type, const QMessageLogContext &context,
                    const QString &message) {
  const char *level = "debug";
  switch (type) {
  case QtInfoMsg:
    level = "info";
    break;
  case QtWarningMsg:
    level = "warning";
    break;
  case QtCriticalMsg:
    level = "critical";
    break;
  case QtFatalMsg:
    level = "fatal";
    break;
  case QtDebugMsg:
    break;
  }

  if (gLogFile && gLogFile->isOpen()) {
    QTextStream out(gLogFile);
    out << QDateTime::currentDateTime().toString(Qt::ISODate) << " [" << level
        << "] " << message;
    if (context.file) {
      out << " (" << context.file << ":" << context.line << ")";
    }
    out << '\n';
    out.flush();
  }

  if (type == QtFatalMsg) {
    abort();
  }
}
} // namespace

int main(int argc, char *argv[]) {
  // 启用高分屏缩放支持 (Qt6 默认开启，但加上以防万一)
  QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
      Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
  QQuickStyle::setStyle(QStringLiteral("Basic"));
  QGuiApplication app(argc, argv);

  QFile logFile(QDir(app.applicationDirPath()).filePath("MeoShowcaseDemo.log"));
  if (logFile.open(QIODevice::WriteOnly | QIODevice::Text |
                   QIODevice::Truncate)) {
    gLogFile = &logFile;
    qInstallMessageHandler(messageHandler);
  }

  qInfo() << "Starting MeoShowcaseDemo from" << app.applicationDirPath();

  // The MeoUI module lives in a linked library, so register its embedded QML
  // resources before resolving the application's QML entry point.
  Q_INIT_RESOURCE(qmake_MeoUI);
  Q_INIT_RESOURCE(meoui_module_raw_qml_0);

  QQmlApplicationEngine engine;

  // 让 QML 引擎能够找到 MeoUI 模块
  engine.addImportPath(app.applicationDirPath() + "/MeoUI");
  engine.addImportPath(app.applicationDirPath());
  engine.addImportPath(app.applicationDirPath() + "/qml");

  const QList<QUrl> entryPoints = {
      QUrl(QStringLiteral("qrc:/qt/qml/MeoUI/showcase/MeoShowcase.qml")),
      QUrl::fromLocalFile(QDir(app.applicationDirPath())
                              .filePath("MeoUI/showcase/MeoShowcase.qml"))};

  for (const QUrl &url : entryPoints) {
    qInfo() << "Loading QML entry point" << url;
    engine.load(url);
    if (!engine.rootObjects().isEmpty()) {
      qInfo() << "Loaded QML root from" << url;
      break;
    }
    qWarning() << "No root object was created from" << url;
  }

  if (engine.rootObjects().isEmpty()) {
    qCritical() << "MeoShowcaseDemo could not create a QML root object.";
    return -1;
  }

  QObject *root = engine.rootObjects().constFirst();
  qInfo() << "Root object class:" << root->metaObject()->className();
  if (auto *window = qobject_cast<QWindow *>(root)) {
    qInfo() << "Root window visible:" << window->isVisible() << "size:"
            << window->size();
    if (!window->isVisible()) {
      window->show();
      qInfo() << "Root window was hidden; show() was called.";
    }
    window->raise();
    window->requestActivate();

    QString screenshotPath;
    for (const QString &argument : app.arguments()) {
      if (argument.startsWith(QStringLiteral("--screenshot="))) {
        screenshotPath = argument.mid(13);
        break;
      }
    }
    if (!screenshotPath.isEmpty()) {
      if (auto *quickWindow = qobject_cast<QQuickWindow *>(window)) {
        QTimer::singleShot(1200, quickWindow,
                           [quickWindow, screenshotPath, &app]() {
          const QImage image = quickWindow->grabWindow();
          if (!image.isNull() && image.save(screenshotPath)) {
            qInfo() << "Saved visual regression image to" << screenshotPath;
            app.quit();
            return;
          }
          qCritical() << "Could not save visual regression image to"
                      << screenshotPath;
          app.exit(2);
        });
        QTimer::singleShot(10000, &app, [&app]() { app.exit(3); });
      }
    }
  } else {
    qWarning() << "QML root object is not a QWindow.";
  }

  const int exitCode = app.exec();
  qInfo() << "MeoShowcaseDemo exited with code" << exitCode;
  return exitCode;
}
