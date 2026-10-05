"""Live desktop and privileged-launch contracts (no host session mutation)."""
import importlib.machinery
import importlib.util
from pathlib import Path
from types import SimpleNamespace
import stat
import subprocess
import tempfile
import unittest
from unittest import mock
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / 'installer/bin/meoarch-live-installer-authorize'
loader = importlib.machinery.SourceFileLoader('live_installer_authorize', str(HELPER))
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)


class LiveAuthorizationTests(unittest.TestCase):
    def setUp(self):
        self.facts = 'User=1000\nActive=yes\nRemote=no\nType=wayland\nClass=user\nDesktop=KDE\n'
        self.user = mock.patch.object(module.pwd, 'getpwnam', return_value=SimpleNamespace(pw_uid=1000))
        self.peer = mock.patch.object(module, 'verify_kwin_endpoint')
        self.peer.start()
        self.addCleanup(self.peer.stop)
        self.user.start()
        self.addCleanup(self.user.stop)

    def context(self, **overrides):
        args = dict(session_id='3', display='wayland-0', caller_uid=1000,
                    cmdline='meoarch.mode=install meoarch.session=plasma', live_media=True)
        args.update(overrides)
        return module.session_context(**args)

    def endpoint_metadata(self):
        return [SimpleNamespace(st_mode=stat.S_IFDIR | 0o700, st_uid=1000),
                SimpleNamespace(st_mode=stat.S_IFSOCK | 0o600, st_uid=1000)]

    def test_active_live_plasma_session_has_bounded_endpoint(self):
        with mock.patch.object(module.subprocess, 'run', return_value=SimpleNamespace(stdout=self.facts)) as run, \
                mock.patch.object(Path, 'lstat', side_effect=self.endpoint_metadata()):
            self.assertEqual(self.context(), Path('/run/user/1000/wayland-0'))
        command = run.call_args.args[0]
        self.assertEqual(command[:3], ['/usr/bin/loginctl', 'show-session', '3'])
        self.assertEqual(run.call_args.kwargs['env'], module.BASE_ENV)
        self.assertEqual(run.call_args.kwargs['timeout'], 5)

    def test_rejects_other_users_media_modes_and_option_injection(self):
        for options in ({'caller_uid': 1001}, {'live_media': False},
                        {'cmdline': 'meoarch.mode=repair'}, {'cmdline': 'meoarch.mode=tty'},
                        {'cmdline': 'meoarch.session=cage'}, {'cmdline': 'meoarch.session=unknown'},
                        {'session_id': '--help'}, {'session_id': '../../root'},
                        {'display': '/tmp/wayland-0'}, {'display': '../wayland-0'},
                        {'display': 'wayland-0;id'}):
            with self.subTest(options=options), mock.patch.object(module.subprocess, 'run') as run:
                with self.assertRaises(ValueError):
                    self.context(**options)
                run.assert_not_called()

    def test_rejects_inactive_remote_wrong_owner_or_non_plasma_logins(self):
        for old, new in (('Active=yes', 'Active=no'), ('Remote=no', 'Remote=yes'),
                         ('User=1000', 'User=0'), ('Type=wayland', 'Type=x11'),
                         ('Class=user', 'Class=greeter'), ('Desktop=KDE', 'Desktop=Hyprland')):
            with self.subTest(new=new), mock.patch.object(module.subprocess, 'run',
                    return_value=SimpleNamespace(stdout=self.facts.replace(old, new))):
                with self.assertRaises(ValueError):
                    self.context()

    def test_rejects_symlink_shared_runtime_and_foreign_socket(self):
        bad_metadata = (
            [SimpleNamespace(st_mode=stat.S_IFLNK | 0o700, st_uid=1000)],
            [SimpleNamespace(st_mode=stat.S_IFDIR | 0o755, st_uid=1000)],
            [SimpleNamespace(st_mode=stat.S_IFDIR | 0o700, st_uid=0)],
            [self.endpoint_metadata()[0], SimpleNamespace(st_mode=stat.S_IFLNK | 0o600, st_uid=1000)],
            [self.endpoint_metadata()[0], SimpleNamespace(st_mode=stat.S_IFSOCK | 0o600, st_uid=0)],
        )
        for metadata in bad_metadata:
            with self.subTest(metadata=metadata), mock.patch.object(module.subprocess, 'run',
                    return_value=SimpleNamespace(stdout=self.facts)), \
                    mock.patch.object(Path, 'lstat', side_effect=metadata):
                with self.assertRaises(ValueError):
                    self.context()

    def test_privileged_launch_strips_injected_paths_and_cleans_marker_after_crash(self):
        child = mock.Mock()
        child.wait.return_value = -9
        poison = {'PKEXEC_UID': '1000', 'QT_PLUGIN_PATH': '/tmp/evil',
                  'PYTHONPATH': '/tmp/evil', 'MEOARCH_INSTALLER_DIR': '/tmp/evil',
                  'DBUS_SESSION_BUS_ADDRESS': 'unix:path=/tmp/evil'}
        with mock.patch.dict(module.os.environ, poison, clear=True), \
                mock.patch.object(module.sys, 'argv', ['helper', '3', 'wayland-0']), \
                mock.patch.object(module.os, 'geteuid', return_value=0), \
                mock.patch.object(Path, 'read_text', return_value='meoarch.mode=install'), \
                mock.patch.object(Path, 'is_dir', return_value=True), \
                mock.patch.object(module, 'session_context', return_value=Path('/run/user/1000/wayland-0')), \
                mock.patch.object(module, 'private_runtime', return_value=50), \
                mock.patch.object(module.os, 'open', side_effect=[51, 52]), \
                mock.patch.object(module.os, 'close'), mock.patch.object(module.fcntl, 'flock'), \
                mock.patch.object(module.signal, 'signal'), \
                mock.patch.object(module, 'reclaim_stale_marker') as reclaim, \
                mock.patch.object(module.os, 'unlink') as unlink, \
                mock.patch.object(module.subprocess, 'Popen', return_value=child) as launch:
            self.assertEqual(module.main(), 137)
        args = launch.call_args.args[0]
        self.assertEqual(args, ['/usr/local/bin/meoarch-installer', '--production',
            '--enable-real-install', '--enable-system-actions', '--', '--desktop-live'])
        self.assertEqual(launch.call_args.kwargs['pass_fds'], (51,))
        reclaim.assert_called_once_with(50, 'production-capability')
        environment = launch.call_args.kwargs['env']
        for name in poison.keys() - {'PKEXEC_UID'}:
            self.assertNotIn(name, environment)
        self.assertEqual(environment['WAYLAND_DISPLAY'], '/run/user/1000/wayland-0')
        self.assertEqual(environment['XDG_RUNTIME_DIR'], '/run/meoarch-installer')
        self.assertEqual(environment['MEOARCH_INSTALLER_STATE_DIR'], '/run/meoarch-installer/state')
        unlink.assert_called_once_with('production-capability', dir_fd=50)

    def test_valid_stale_marker_reclaimed_but_unsafe_objects_preserved(self):
        good = dict(st_mode=stat.S_IFREG | 0o600, st_uid=0, st_gid=0, st_nlink=1, st_size=0)
        with mock.patch.object(module.os, 'stat', return_value=SimpleNamespace(**good)), \
                mock.patch.object(module.os, 'unlink') as unlink:
            module.reclaim_stale_marker(50, 'production-capability')
            unlink.assert_called_once_with('production-capability', dir_fd=50)
        for changes in ({'st_mode': stat.S_IFLNK | 0o600}, {'st_uid': 1000},
                        {'st_gid': 1000}, {'st_nlink': 2}, {'st_size': 1},
                        {'st_mode': stat.S_IFREG | 0o644}):
            with self.subTest(changes=changes), mock.patch.object(module.os, 'stat',
                    return_value=SimpleNamespace(**(good | changes))), \
                    mock.patch.object(module.os, 'unlink') as unlink:
                with self.assertRaises(ValueError):
                    module.reclaim_stale_marker(50, 'production-capability')
                unlink.assert_not_called()

    def test_child_inherits_lock_after_launcher_death(self):
        # Real kernel flock lifetime across exec/parent death; no privileged
        # session or Installer process is involved in this regression test.
        import fcntl
        import os
        import sys
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'lock'
            parent_code = """import fcntl, os, subprocess, sys
fd = os.open(sys.argv[1], os.O_CREAT | os.O_RDWR, 0o600)
fcntl.flock(fd, fcntl.LOCK_EX)
p = subprocess.Popen([sys.executable, '-c', 'import sys; sys.stdin.buffer.read(1)'], pass_fds=(fd,))
print(p.pid, flush=True)
os._exit(0)
"""
            parent = subprocess.Popen([sys.executable, '-c', parent_code, str(path)],
                                      stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            self.assertTrue(parent.stdout.readline().strip().isdigit())
            parent.wait(timeout=5)
            contender = os.open(path, os.O_RDWR)
            try:
                with self.assertRaises(BlockingIOError):
                    fcntl.flock(contender, fcntl.LOCK_EX | fcntl.LOCK_NB)
                parent.stdin.write(b'x')
                parent.stdin.flush()
                import time
                deadline = time.monotonic() + 5
                while True:
                    try:
                        fcntl.flock(contender, fcntl.LOCK_EX | fcntl.LOCK_NB)
                        break
                    except BlockingIOError:
                        if time.monotonic() >= deadline:
                            self.fail('Inherited lock did not release on child exit')
                        time.sleep(0.01)
            finally:
                os.close(contender)
                parent.stdin.close()
                parent.stdout.close()

    def test_extra_flags_and_direct_root_launch_are_rejected(self):
        for args, env in ((['helper', '3', 'wayland-0', '--preview'], {'PKEXEC_UID': '1000'}),
                          (['helper', '3', 'wayland-0'], {})):
            with self.subTest(args=args, env=env), mock.patch.object(module.sys, 'argv', args), \
                    mock.patch.dict(module.os.environ, env, clear=True), \
                    mock.patch.object(module.os, 'geteuid', return_value=0):
                with self.assertRaises(ValueError):
                    module.main()


class KWinEndpointTests(unittest.TestCase):
    def test_substituted_compositor_rejected_even_for_live_owned_socket(self):
        import struct
        endpoint = Path('/run/user/1000/wayland-0')
        connection = mock.MagicMock()
        connection.__enter__.return_value = connection
        connection.getsockopt.return_value = struct.pack('3i', 1234, 1000, 1000)
        for exe, bus_pid, cgroup, okay in (
            ('/usr/bin/python3', 'u 1234', '/user.slice/user-1000.slice/user@1000.service', False),
            ('/usr/bin/kwin_wayland', 'u 9999', '/user.slice/user-1000.slice/user@1000.service', False),
            ('/usr/bin/kwin_wayland', 'u 1234', '/system.slice/fake.service', False),
            ('/usr/bin/kwin_wayland', 'u 1234', '/user.slice/user-1000.slice/user@1000.service/session.slice/kwin.service', True),
        ):
            with self.subTest(exe=exe, bus_pid=bus_pid, cgroup=cgroup), \
                    mock.patch.object(module.socket, 'socket', return_value=connection), \
                    mock.patch.object(Path, 'resolve', return_value=Path(exe)), \
                    mock.patch.object(Path, 'stat', return_value=SimpleNamespace(st_uid=0, st_mode=0o755)), \
                    mock.patch.object(Path, 'read_text', return_value='0::' + cgroup), \
                    mock.patch.object(module.subprocess, 'run', return_value=SimpleNamespace(stdout=bus_pid)):
                if okay:
                    module.verify_kwin_endpoint(endpoint, 1000)
                else:
                    with self.assertRaises(ValueError):
                        module.verify_kwin_endpoint(endpoint, 1000)


class LiveDesktopContractTests(unittest.TestCase):
    def read(self, path):
        return (ROOT / path).read_text()

    def test_default_desktop_and_kiosk_are_mutually_exclusive(self):
        profile = ROOT / 'meoarch-os/airootfs/etc/systemd/system'
        self.assertEqual((profile / 'display-manager.service').readlink(),
                         Path('/usr/lib/systemd/system/plasmalogin.service'))
        self.assertIn('ConditionKernelCommandLine=!meoarch.session=cage',
                      (profile / 'plasmalogin.service.d/20-meoarch-live.conf').read_text())
        self.assertIn('ConditionKernelCommandLine=meoarch.session=cage',
                      (profile / 'meoarch-installer.service').read_text())
        config = self.read('meoarch-os/airootfs/etc/plasmalogin.conf')
        for line in ('[Autologin]', 'User=live', 'Session=meoarch-live.desktop', 'Relogin=true'):
            self.assertIn(line, config)

    def test_autostart_cannot_own_or_restart_plasma(self):
        service = self.read('installer/data/systemd/user/meoarch-live-app.service')
        self.assertIn('Restart=no', service)
        self.assertIn('Type=exec', service)
        self.assertNotIn('RemainAfterExit', service)
        self.assertNotIn('TimeoutStartSec=infinity', service)
        self.assertNotIn('plasmashell', service)
        self.assertNotIn('Requires=', service)
        self.assertNotIn('BindsTo=', service)
        launcher = self.read('installer/bin/meoarch-installer-live')
        self.assertIn('org.kde.KWin', launcher)
        self.assertNotIn('org.kde.plasmashell', launcher)
        self.assertNotIn('XDG_RUNTIME_DIR:?', launcher)
        self.assertNotIn('WAYLAND_DISPLAY:?}/${', launcher)
        self.assertIn('attempt<60', launcher)
        self.assertNotIn('network-online.target', launcher)
        autostart = self.read('installer/data/autostart/meoarch-live.desktop')
        self.assertIn('OnlyShowIn=KDE;', autostart)
        self.assertIn('--autostart', autostart)
        qml = self.read('installer/qml/Main.qml')
        self.assertIn('root.desktopLive ? Window.FullScreen', qml)

    def test_live_rule_is_one_fixed_program_and_installed_target_forbids_it(self):
        policy = ET.parse(ROOT / 'installer/data/org.meo.installer-live.policy').getroot()
        actions = policy.findall('action')
        self.assertEqual([a.get('id') for a in actions], ['org.meo.installer.live.launch'])
        self.assertEqual(actions[0].find("annotate[@key='org.freedesktop.policykit.exec.path']").text,
                         '/usr/lib/meoarch/live-installer-authorize')
        for tag in ('allow_any', 'allow_inactive', 'allow_active'):
            self.assertEqual(actions[0].find(f'defaults/{tag}').text, 'no')
        rules = self.read('installer/data/org.meo.installer-live.rules')
        for condition in ('subject.user === "live"', 'subject.local === true',
                          'subject.active === true', 'action.lookup("user") === "root"'):
            self.assertIn(condition, rules)
        self.assertFalse((ROOT / 'meoarch-os/airootfs/etc/sudoers.d/10-meoarch-live-installer').exists())
        verify = self.read('installer/backend/verify-target.py')
        self.assertIn('usr/lib/meoarch/live-installer-authorize', verify)
        self.assertIn('etc/xdg/autostart/meoarch-live.desktop', verify)

    def test_provenance_accepts_desktop_inputs_and_rejects_unknown_payload(self):
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary) / 'baseline'
            staged = Path(temporary) / 'staged'
            base.mkdir()
            staged.mkdir()
            paths = ('airootfs/usr/lib/meoarch/live-installer-authorize',
                     'airootfs/etc/xdg/autostart/meoarch-live.desktop',
                     'airootfs/usr/share/plasma/plasmoids/org.meo.toptasks/metadata.json',
                     'airootfs/usr/share/plasma/plasmoids/org.meo.widgetexplorer/metadata.json',
                     'airootfs/etc/xdg/meo-shellrc',
                     'airootfs/usr/lib/systemd/user/plasma-workspace.target.wants/plasma-polkit-agent.service')
            for relative in paths:
                item = staged / relative
                item.parent.mkdir(parents=True, exist_ok=True)
                item.write_text('source-backed test input')
            manifest = Path(temporary) / 'manifest.tsv'
            command = ['bash', str(ROOT / 'scripts/verify-staging-provenance.sh'),
                       str(base), str(staged), str(manifest)]
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('UNDECLARED', manifest.read_text())
            (staged / 'unreviewed-payload').write_text('unknown')
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('UNDECLARED', manifest.read_text())

    def test_desktop_and_installer_use_their_existing_system_plugins(self):
        sync = self.read('scripts/sync-installer-to-airootfs.sh')
        self.assertIn('cp -a "${meosystem_build}/qml/Meo/System/." "${meosystem_qml_dst}/"', sync)
        self.assertIn('"${installer_dst}/live-qml/Meo/System/"', sync)
        self.assertIn('org.meo.toptasks', sync)
        self.assertIn('org.meo.widgetexplorer', sync)
        self.assertIn('desktop-ready', self.read('installer/bin/meo-boot-status'))


if __name__ == '__main__':
    unittest.main()
