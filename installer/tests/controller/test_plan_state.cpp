#include "../../app/installercontroller.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QtTest>

// Only a disposable backend fixture is executed; no archinstall or disk access.
class PlanStateTests : public QObject
{
    Q_OBJECT
private:
    void write(const QString &path, const QByteArray &contents)
    {
        QDir().mkpath(QFileInfo(path).absolutePath());
        QFile file(path);
        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(file.write(contents), contents.size());
        file.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner);
    }

    void configureFixture(const QTemporaryDir &fixture)
    {
        QVERIFY(fixture.isValid());
        qputenv("TMPDIR", fixture.path().toUtf8());
        qputenv("MEOARCH_INSTALLER_ROOT", fixture.path().toUtf8());
        qunsetenv("MEOARCH_INSTALLER_STATE_DIR");
        qunsetenv("MEO_TEST_DELAY_STAGE");
        qunsetenv("MEO_TEST_COMPLETE_EVENT");
    }

    void writeReadyBackend(const QString &directory)
    {
        const auto script = QByteArray(R"PY(
import json, os, pathlib, sys
stage = 'generator' if '--state-dir' in sys.argv else 'preflight'
state = pathlib.Path(sys.argv[sys.argv.index('--state-dir') + 1] if stage == 'generator'
                     else os.environ['MEOARCH_INSTALLER_STATE_DIR'])
if stage == 'generator':
    (state / 'generated').mkdir(exist_ok=True)
    plan = {'schemaVersion': 2, 'repository': {'repositories': ['meo']},
            'package': {'packages': ['meo-desktop']}, 'applications': {'source': 'arch-official'}}
    (state / 'generated/install-plan.json').write_text(json.dumps(plan))
else:
    (state / 'preflight_status.json').write_text(json.dumps({'state': 'complete'}))
)PY");
        write(directory + "/backend/generate-config.py", script);
        write(directory + "/backend/archinstall-preflight.sh", "#!/usr/bin/env python3\n" + script);
    }

    void prepareReady(InstallerController &controller)
    {
        QSignalSpy account(&controller, &InstallerController::accountReady);
        controller.saveAccount("Disposable Test", "meotest", "meotest", "Fixture-Only-123!", "Fixture-Only-123!");
        QTRY_COMPARE(account.count(), 1);
        controller.prepareInstallation();
        QTRY_VERIFY(controller.readyToInstall());
    }

private slots:
    void staleCompletion_data()
    {
        QTest::addColumn<QString>("delayedStage");
        QTest::newRow("generator") << "generator";
        QTest::newRow("preflight") << "preflight";
    }

    void staleCompletion()
    {
        QFETCH(QString, delayedStage);
        QTemporaryDir fixture(QStringLiteral("/tmp/meo-controller-XXXXXX"));
        QVERIFY(fixture.isValid());
        const auto directory = fixture.path();
        qputenv("TMPDIR", directory.toUtf8());
        qputenv("MEOARCH_INSTALLER_ROOT", directory.toUtf8());
        qputenv("MEO_TEST_DELAY_STAGE", delayedStage.toUtf8());
        const auto state = directory + "/meoarch-installer";
        const auto script = QByteArray(R"PY(
import json, os, pathlib, sys, time
stage = 'generator' if '--state-dir' in sys.argv else 'preflight'
state = pathlib.Path(sys.argv[sys.argv.index('--state-dir') + 1] if stage == 'generator'
                     else os.environ['MEOARCH_INSTALLER_STATE_DIR'])
if stage == os.environ['MEO_TEST_DELAY_STAGE']:
    (state / 'waiting').touch()
    deadline = time.monotonic() + 10
    while not (state / 'release').exists():
        if time.monotonic() > deadline:
            sys.exit(1)
        time.sleep(0.02)
if stage == 'generator':
    (state / 'generated').mkdir(exist_ok=True)
    plan = {'schemaVersion': 2, 'repository': {'repositories': ['meo']},
            'package': {'packages': ['meo-desktop']}, 'applications': {'source': 'arch-official'}}
    (state / 'generated/install-plan.json').write_text(json.dumps(plan))
else:
    (state / 'preflight_status.json').write_text(json.dumps({'state': 'complete'}))
(state / (stage + '-finished')).touch()
)PY");
        write(directory + "/backend/generate-config.py", script);
        write(directory + "/backend/archinstall-preflight.sh", "#!/usr/bin/env python3\n" + script);

        InstallerController controller({});
        QSignalSpy account(&controller, &InstallerController::accountReady);
        controller.saveAccount("Disposable Test", "meotest", "meotest", "Fixture-Only-123!", "Fixture-Only-123!");
        QTRY_COMPARE(account.count(), 1);
        controller.prepareInstallation();
        QTRY_VERIFY(QFile::exists(state + "/waiting"));
        controller.setSelection("software", "profile", "minimal");
        QVERIFY(!controller.readyToInstall());
        QVERIFY(controller.installPlan().isEmpty());
        QVERIFY(!QFile::exists(state + "/generated/install-plan.json"));
        // Retrying cannot create a second writer to the same state directory.
        controller.prepareInstallation();
        QVERIFY(controller.errorMessage().contains("previous preparation"));
        write(state + "/release", "continue");
        QTRY_VERIFY(QFile::exists(state + "/" + delayedStage + "-finished"));
        QTRY_VERIFY(!QFile::exists(state + "/generated/install-plan.json"));
        QTRY_VERIFY(!QFile::exists(state + "/preflight_status.json"));
        // Drain the completion signal; the stale callback must never revive ready.
        QTest::qWait(100);
        QVERIFY(!controller.readyToInstall());
        QVERIFY(controller.installPlan().isEmpty());
        controller.confirmSummary();
        QVERIFY(!QFile::exists(state + "/summary_confirmed"));
    }

    void backendExitRequiresVerifiedCompletionEvent()
    {
        QTemporaryDir fixture(QStringLiteral("/tmp/meo-controller-XXXXXX"));
        configureFixture(fixture);
        const QString directory = fixture.path();
        const QString state = directory + "/meoarch-installer";
        writeReadyBackend(directory);
        // A completion event from an old session must not authorize the next
        // backend process when it exits without producing a fresh terminal
        // event.
        write(state + "/logs/install-events.jsonl",
              "{\"event\":\"stage\",\"id\":\"complete\",\"progress\":100,\"message\":\"Old completion\"}\n");
        write(directory + "/backend/run-archinstall.sh", R"SH(#!/usr/bin/env bash
set -euo pipefail
state_dir="${MEOARCH_INSTALLER_STATE_DIR:?}"
mkdir -p "${state_dir}/logs"
count_file="${state_dir}/backend-start-count"
count=0
if [ -f "${count_file}" ]; then read -r count < "${count_file}"; fi
printf '%s\n' "$((count + 1))" > "${count_file}"
touch "${state_dir}/backend-started"
while [ ! -e "${state_dir}/backend-release" ]; do sleep 0.02; done
if [ "${MEO_TEST_COMPLETE_EVENT:-0}" = 1 ]; then
  printf '%s\n' '{"event":"stage","id":"complete","progress":100,"message":"Installation complete"}' >> "${state_dir}/logs/install-events.jsonl"
fi
)SH");

        InstallerController controller({QStringLiteral("--production"), QStringLiteral("--enable-real-install")});
        prepareReady(controller);
        controller.confirmSummary();
        controller.startInstallation();
        QTRY_VERIFY(QFile::exists(state + "/backend-started"));
        QCOMPARE(controller.installationState(), QStringLiteral("running"));

        // A second activation must not start a second destructive backend.
        controller.startInstallation();
        QFile count(state + "/backend-start-count");
        QVERIFY(count.open(QIODevice::ReadOnly));
        QCOMPARE(QString::fromUtf8(count.readAll()).trimmed(), QStringLiteral("1"));
        QVERIFY(controller.errorMessage().contains(QStringLiteral("already running")));

        write(state + "/backend-release", "continue");
        QTRY_COMPARE(controller.installationState(), QStringLiteral("failed"));
        QVERIFY(controller.installationFailureDetails().contains(QStringLiteral("verified completion event")));
    }

    void backendCompletionEventAllowsComplete()
    {
        QTemporaryDir fixture(QStringLiteral("/tmp/meo-controller-XXXXXX"));
        configureFixture(fixture);
        qputenv("MEO_TEST_COMPLETE_EVENT", "1");
        const QString directory = fixture.path();
        const QString state = directory + "/meoarch-installer";
        writeReadyBackend(directory);
        write(directory + "/backend/run-archinstall.sh", R"SH(#!/usr/bin/env bash
set -euo pipefail
state_dir="${MEOARCH_INSTALLER_STATE_DIR:?}"
mkdir -p "${state_dir}/logs"
touch "${state_dir}/backend-started"
while [ ! -e "${state_dir}/backend-release" ]; do sleep 0.02; done
printf '%s\n' '{"event":"stage","id":"complete","progress":100,"message":"Installation complete"}' >> "${state_dir}/logs/install-events.jsonl"
)SH");

        InstallerController controller({QStringLiteral("--production"), QStringLiteral("--enable-real-install")});
        prepareReady(controller);
        controller.confirmSummary();
        controller.startInstallation();
        QTRY_VERIFY(QFile::exists(state + "/backend-started"));
        write(state + "/backend-release", "continue");
        QTRY_COMPARE(controller.installationState(), QStringLiteral("complete"));
        QCOMPARE(controller.installationProgress(), 100);
    }

    void backendFailedToStartDoesNotLeaveRunningState()
    {
        QTemporaryDir fixture(QStringLiteral("/tmp/meo-controller-XXXXXX"));
        configureFixture(fixture);
        const QString directory = fixture.path();
        writeReadyBackend(directory);
        const QString backend = directory + "/backend/run-archinstall.sh";
        write(backend, "#!/usr/bin/env bash\nexit 0\n");
        QFile backendFile(backend);
        QVERIFY(backendFile.setPermissions(QFile::ReadOwner | QFile::WriteOwner));

        InstallerController controller({QStringLiteral("--production"), QStringLiteral("--enable-real-install")});
        prepareReady(controller);
        controller.confirmSummary();
        controller.startInstallation();
        QTRY_COMPARE(controller.installationState(), QStringLiteral("failed"));
        QVERIFY(controller.installationFailureDetails().contains(QStringLiteral("could not be started")));
    }

    void accountHashAndPowerActionsHaveControllerGuards()
    {
        QTemporaryDir fixture(QStringLiteral("/tmp/meo-controller-XXXXXX"));
        configureFixture(fixture);
        writeReadyBackend(fixture.path());

        InstallerController controller({QStringLiteral("--production"), QStringLiteral("--enable-system-actions")});
        QSignalSpy account(&controller, &InstallerController::accountReady);
        controller.saveAccount("Disposable Test", "meotest", "meotest", "Fixture-Only-123!", "Fixture-Only-123!");
        controller.prepareInstallation();
        QVERIFY(controller.errorMessage().contains(QStringLiteral("still being prepared")));
        // A second account save supersedes the first asynchronous hash result.
        controller.saveAccount("Disposable Test", "meotest", "meotest", "Fixture-Only-456!", "Fixture-Only-456!");
        QTRY_COMPARE(account.count(), 1);
        QTest::qWait(100);
        QCOMPARE(account.count(), 1);

        controller.requestRestart();
        QVERIFY(controller.errorMessage().contains(QStringLiteral("only after target validation")));
        controller.requestShutdown();
        QVERIFY(controller.errorMessage().contains(QStringLiteral("only after target validation")));
    }

    void productionKioskDoesNotExposeDebugShell()
    {
        QTemporaryDir fixture(QStringLiteral("/tmp/meo-controller-XXXXXX"));
        configureFixture(fixture);

        InstallerController controller({QStringLiteral("--production")});
        QVERIFY(!controller.debugTerminalAvailable());
        controller.openDebugTerminal();
        QVERIFY(controller.errorMessage().contains(QStringLiteral("disabled in the production installer")));
    }
};

QTEST_GUILESS_MAIN(PlanStateTests)
#include "test_plan_state.moc"
