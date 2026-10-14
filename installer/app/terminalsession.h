#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QString>

class TerminalSession final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY changed)
    Q_PROPERTY(QString output READ output NOTIFY changed)
public:
    explicit TerminalSession(QObject *parent = nullptr);
    ~TerminalSession() override;

    bool running() const { return m_pid > 0; }
    QString output() const { return m_output; }

    bool start();
    Q_INVOKABLE void write(const QString &text);
    Q_INVOKABLE void sendInterrupt();
    Q_INVOKABLE void resize(int columns, int rows);
    Q_INVOKABLE void clear();
    void stop();

signals:
    void changed();

private slots:
    void readOutput();

private:
    void appendOutput(const QByteArray &bytes);
    int m_fd = -1;
    qint64 m_pid = -1;
    QSocketNotifier *m_notifier = nullptr;
    QString m_output;
};