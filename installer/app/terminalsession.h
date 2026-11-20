#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QString>
#include <QStringDecoder>

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
    void appendDisplayText(const QString &text);
    void trimToLastLine();

    // The view is a plain text area, not a terminal emulator. Escape
    // sequences are removed and backspace/carriage return are applied so the
    // log stays readable. State is kept across reads because a sequence or a
    // multi-byte UTF-8 character can be split between two chunks.
    enum class EscapeState { None, Escape, Csi, Osc, OscEscape };
    EscapeState m_escape = EscapeState::None;
    bool m_pendingCarriageReturn = false;
    QStringDecoder m_decoder{QStringDecoder::Utf8};
    int m_fd = -1;
    qint64 m_pid = -1;
    QSocketNotifier *m_notifier = nullptr;
    QString m_output;
};