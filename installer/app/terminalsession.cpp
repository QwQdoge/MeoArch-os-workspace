#include "terminalsession.h"

#include <QByteArray>
#include <QDir>
#include <QFile>
#include <QProcessEnvironment>

#ifdef Q_OS_LINUX
#include <pty.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>
#endif

namespace {
constexpr qsizetype MaximumOutputBytes = 2 * 1024 * 1024;
}

TerminalSession::TerminalSession(QObject *parent)
    : QObject(parent)
{
}

TerminalSession::~TerminalSession()
{
    stop();
}

bool TerminalSession::start()
{
#ifndef Q_OS_LINUX
    return false;
#else
    if (running())
        return true;
    passwd *live = getpwnam("live");
    if (!live || live->pw_uid == 0)
        return false;

    termios settings{};
    ::cfmakeraw(&settings);
    settings.c_cc[VMIN] = 1;
    settings.c_cc[VTIME] = 0;
    winsize size{24, 80, 0, 0};
    int fd = -1;
    const pid_t child = ::forkpty(&fd, nullptr, &settings, &size);
    if (child < 0)
        return false;
    if (child == 0) {
        const char *shell = live->pw_shell && live->pw_shell[0] == '/' ? live->pw_shell : "/usr/bin/bash";
        ::execl("/usr/bin/setpriv", "setpriv", "--reuid=live", "--regid=live",
                "--clear-groups", "--no-new-privs", "--bounding-set=-all",
                "--inh-caps=-all", "--ambient-caps=-all", "/usr/bin/env", "-i",
                "HOME=/home/live", "USER=live", "LOGNAME=live",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/bin", "TERM=xterm-256color",
                "COLORTERM=truecolor", "HISTFILE=/dev/null", shell, "-i", nullptr);
        _exit(127);
    }
    m_fd = fd;
    m_pid = child;
    m_notifier = new QSocketNotifier(m_fd, QSocketNotifier::Read, this);
    connect(m_notifier, &QSocketNotifier::activated, this, [this] { readOutput(); });
    emit changed();
    return true;
#endif
}

void TerminalSession::write(const QString &text)
{
#ifdef Q_OS_LINUX
    if (m_fd >= 0) {
        const QByteArray bytes = text.toUtf8();
        (void)::write(m_fd, bytes.constData(), static_cast<size_t>(bytes.size()));
    }
#else
    Q_UNUSED(text)
#endif
}

void TerminalSession::sendInterrupt()
{
#ifdef Q_OS_LINUX
    if (m_fd >= 0)
        ::write(m_fd, "\003", 1);
#endif
}

void TerminalSession::resize(int columns, int rows)
{
#ifdef Q_OS_LINUX
    if (m_fd >= 0 && columns > 0 && rows > 0) {
        winsize size{static_cast<unsigned short>(rows), static_cast<unsigned short>(columns), 0, 0};
        ::ioctl(m_fd, TIOCSWINSZ, &size);
    }
#else
    Q_UNUSED(columns)
    Q_UNUSED(rows)
#endif
}

void TerminalSession::clear()
{
    m_output.clear();
    emit changed();
}

void TerminalSession::readOutput()
{
#ifdef Q_OS_LINUX
    char buffer[16384];
    const ssize_t count = ::read(m_fd, buffer, sizeof(buffer));
    if (count > 0) {
        appendOutput(QByteArray(buffer, static_cast<int>(count)));
        return;
    }
    stop();
#endif
}

void TerminalSession::appendOutput(const QByteArray &bytes)
{
    m_output += QString::fromUtf8(bytes);
    if (m_output.size() > MaximumOutputBytes)
        m_output.remove(0, m_output.size() - MaximumOutputBytes);
    emit changed();
}

void TerminalSession::stop()
{
#ifdef Q_OS_LINUX
    if (m_notifier) {
        m_notifier->setEnabled(false);
        m_notifier->deleteLater();
        m_notifier = nullptr;
    }
    if (m_fd >= 0) {
        ::close(m_fd);
        m_fd = -1;
    }
    if (m_pid > 0) {
        ::kill(static_cast<pid_t>(m_pid), SIGHUP);
        int status = 0;
        (void)::waitpid(static_cast<pid_t>(m_pid), &status, 0);
        m_pid = -1;
        emit changed();
    }
#endif
}