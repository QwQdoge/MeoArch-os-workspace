"""Crash-loop recovery decisions and stock configuration isolation."""
import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
loader = importlib.machinery.SourceFileLoader('live_session', str(ROOT / 'installer/bin/meoarch-live-session'))
spec = importlib.util.spec_from_loader(loader.name, loader)
session = importlib.util.module_from_spec(spec)
loader.exec_module(session)


class LiveSessionTests(unittest.TestCase):
    def test_two_short_failures_select_safe_mode_and_old_failures_expire(self):
        failures = session.record_exit([], 10, 5)
        self.assertLess(len(failures), session.LIMIT)
        failures = session.record_exit(failures, 16, 5)
        self.assertEqual(len(failures), session.LIMIT)
        self.assertEqual(session.record_exit(failures, 90, 5), [90])
        self.assertEqual(session.record_exit(failures, 90, 65), [90])
        self.assertEqual(session.record_exit([1000], 10, 2), [10])

    def test_safe_mode_uses_clean_stock_profile_and_drops_custom_layout(self):
        with tempfile.TemporaryDirectory() as temporary:
            state = Path(temporary)
            config = state / 'safe-config'
            config.mkdir()
            custom = config / 'plasma-org.kde.plasma.desktop-appletsrc'
            custom.write_text('plugin=org.meo.topbar')
            env = session.safe_environment({'WAYLAND_DISPLAY': 'wayland-1'}, state)
            self.assertEqual(env['XDG_CONFIG_HOME'], str(config))
            self.assertEqual(env['QT_STYLE_OVERRIDE'], 'Breeze')
            self.assertEqual(env['WAYLAND_DISPLAY'], 'wayland-1')
            self.assertFalse(custom.exists())
            self.assertIn('LookAndFeelPackage=org.kde.breeze.desktop', (config / 'kdeglobals').read_text())
            self.assertIn('kwin4_effect_shapecornersEnabled=false', (config / 'kwinrc').read_text())
            self.assertIn('library=org.kde.breeze', (config / 'kwinrc').read_text())

    def test_tty2_is_always_live_only_unprivileged_and_enabled(self):
        profile = ROOT / 'meoarch-os/airootfs/etc/systemd/system'
        unit = (profile / 'getty@tty2.service.d/20-meoarch-live.conf').read_text()
        self.assertIn('ConditionPathExists=/run/archiso', unit)
        self.assertNotIn('ConditionKernelCommandLine=', unit)
        self.assertIn('--autologin live', unit)
        self.assertNotIn('--autologin root', unit)
        self.assertEqual((profile / 'getty.target.wants/getty@tty2.service').readlink(),
                         Path('/usr/lib/systemd/system/getty@.service'))


if __name__ == '__main__':
    unittest.main()
