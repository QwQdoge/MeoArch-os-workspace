import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(sys.platform.startswith('linux'), 'ArchISO uses GNU sed')
class BuildGpgHomeTests(unittest.TestCase):
    def test_short_public_home_and_exit_cleanup(self):
        script = (ROOT / 'scripts/build-iso.sh').read_text()
        section = script.split('build_gpg_dir="$(mktemp', 1)[1]
        section = 'build_gpg_dir="$(mktemp' + section.split(
            'if [ -n "${MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY:-}" ]; then', 1)[0]
        for exit_status in (0, 17):
            with self.subTest(exit_status=exit_status), tempfile.TemporaryDirectory() as tmp:
                profile = Path(tmp) / ('long-profile-' * 12)
                seed = profile / 'airootfs/etc/pacman.d/gnupg'
                seed.mkdir(parents=True)
                for name in ('pubring.gpg', 'trustdb.gpg', 'gpg.conf'):
                    (seed / name).write_text('public fixture')
                (seed / 'private-key').write_text('must never be copied')
                (profile / 'pacman.conf').write_text('[options]\nSigLevel = Required\n')
                command = section + '\nprintf "%s\\n" "$build_gpg_dir"\nls -A "$build_gpg_dir"\nexit ' + str(exit_status)
                result = subprocess.run(['bash', '-Eeuo', 'pipefail', '-c', command],
                                        env={**os.environ, 'staged_profile': str(profile)},
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, exit_status, result.stderr)
                lines = result.stdout.splitlines()
                short_home = Path(lines[0])
                self.assertEqual(short_home.parent, Path('/tmp'))
                self.assertEqual(set(lines[1:]), {'gpg.conf', 'pubring.gpg', 'trustdb.gpg'})
                self.assertFalse(short_home.exists())
                self.assertEqual((profile / 'pacman.conf').read_text(),
                                 f'[options]\nGPGDir = {short_home}\nSigLevel = Required\n')

    def test_provenance_rejects_signature_or_repository_changes(self):
        with tempfile.TemporaryDirectory() as tmp:
            baseline, staged = Path(tmp) / 'baseline', Path(tmp) / 'staged'
            baseline.mkdir()
            staged.mkdir()
            original = '[options]\nSigLevel = Required\n[meo]\nServer = https://example.invalid\n'
            (baseline / 'pacman.conf').write_text(original)
            generated = original.replace('[options]\n', '[options]\nGPGDir = /tmp/meo-archiso-build-gpg.Abc123\n')
            for contents, expected in ((generated, 0),
                                       (generated.replace('Required', 'Never'), 1),
                                       (generated.replace('example.invalid', 'untrusted.invalid'), 1),
                                       (generated.replace('/tmp/meo-archiso-build-gpg.Abc123', '/etc/pacman.d/gnupg'), 1)):
                (staged / 'pacman.conf').write_text(contents)
                result = subprocess.run(['bash', str(ROOT / 'scripts/verify-staging-provenance.sh'),
                                         str(baseline), str(staged), str(Path(tmp) / 'manifest')],
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, expected, result.stderr)


if __name__ == '__main__':
    unittest.main()
