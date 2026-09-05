"""Exercise target bootstrap ordering without mounting or modifying a disk."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).parents[1]


class ConfigureRepositoryTests(unittest.TestCase):
    def test_fresh_target_syncs_stable_before_bootstrap_then_selected_channel(self):
        for channel, repos in (("stable", ["meo"]), ("beta", ["meo-beta", "meo"])):
            with self.subTest(channel=channel), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                target, generated, bootstrap, binaries = (root / name for name in ("target", "generated", "bootstrap", "bin"))
                for path in (target / "etc", generated, bootstrap, binaries):
                    path.mkdir(parents=True)
                (target / "etc/pacman.conf").write_text("[options]\nArchitecture = auto\n")
                (generated / "install-plan.json").write_text(json.dumps({"repository": {
                    "channel": channel, "channelPackage": f"meo-channel-{channel}", "repositories": repos}}))
                for name in ("meo.gpg", "meo-trusted", "meo-revoked"):
                    (bootstrap / name).write_text("disposable ordering fixture\n")
                log = root / "calls"
                chroot = binaries / "arch-chroot"
                chroot.write_text('#!/bin/bash\nset -eu\nshift\nprintf "%s\\n" "$*" >>"$CALL_LOG"\n'
                                  'if [ "$1" = pacman-conf ]; then printf "%s\\n" "$REPO_LIST"; fi\n')
                chroot.chmod(0o755)
                env = dict(os.environ, PATH=f"{binaries}:{os.environ['PATH']}", CALL_LOG=str(log), REPO_LIST="\n".join(repos))
                result = subprocess.run([ROOT / "backend/configure-meo-repository.sh", target, generated, bootstrap],
                                        env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                calls = log.read_text().splitlines()
                sync = next(index for index, call in enumerate(calls) if call.endswith(" -Sy --noconfirm"))
                install = next(index for index, call in enumerate(calls) if call.endswith(
                    f" -S --needed --noconfirm meo/meo-keyring meo/meo-mirrorlist meo/meo-channel-{channel}"))
                self.assertLess(sync, install)
                self.assertLess(install, calls.index("pacman -Syy --noconfirm"))
                self.assertTrue(any("--populate-from /etc/meo-bootstrap." in call for call in calls))
                self.assertFalse(any("/run/meo-bootstrap." in call or "/tmp/meo-bootstrap." in call for call in calls))
                self.assertFalse((target / "usr/share/pacman/keyrings/meo.gpg").exists())
                self.assertFalse((target / "etc/pacman.d/meo-channel.conf").exists())
                self.assertFalse((target / "etc/pacman.d/meo-mirrorlist").exists())
