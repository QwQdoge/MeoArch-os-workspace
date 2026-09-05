#include "../../app/installercontroller.h"
#include <QDir>
#include <QFile>
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
};

QTEST_GUILESS_MAIN(PlanStateTests)
#include "test_plan_state.moc"
