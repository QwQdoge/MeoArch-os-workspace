"""Exercise both launchers with a fake QEMU, without allocating a VM."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class VmResourceTests(unittest.TestCase):
    def launch(self, script, overrides):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            tools = root / "bin"
            tools.mkdir()
            fake = tools / "qemu-system-x86_64"
            fake.write_text("#!/usr/bin/env python3\nimport json,sys\nprint(json.dumps(sys.argv[1:]))\n")
            fake.chmod(0o755)
            for name in ("disk.qcow2", "test.iso", "code.fd", "vars.fd"):
                (root / name).touch()
            env = dict(os.environ, PATH=f"{tools}:{os.environ['PATH']}",
                       MEOARCH_RUN_DIR=str(root / "evidence"),
                       MEOARCH_VM_DIR=str(root / "vm"),
                       MEOARCH_QEMU_SOCKET_DIR=str(root / "q"),
                       MEOARCH_OVMF_CODE=str(root / "code.fd"),
                       MEOARCH_OVMF_VARS=str(root / "vars.fd"), **overrides)
            args = [str(root / "disk.qcow2")]
            if script.startswith("60"):
                args.insert(0, str(root / "test.iso"))
            result = subprocess.run(["bash", str(ROOT / "scripts/acceptance" / script), *args],
                                    env=env, text=True, capture_output=True)
            return result

    def test_safe_defaults_and_overrides_reach_both_qemu_commands(self):
        for script in ("60-boot-live.sh", "70-boot-installed.sh"):
            for overrides, cpus, memory in (({}, "2", "4096"),
                    ({"MEOARCH_VM_CPUS": "3", "MEOARCH_VM_MEMORY_MIB": "3072"}, "3", "3072")):
                with self.subTest(script=script, overrides=overrides):
                    result = self.launch(script, overrides)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    command = json.loads(result.stdout)
                    self.assertEqual(command[command.index("-smp") + 1], cpus)
                    self.assertEqual(command[command.index("-m") + 1], memory)

    def test_invalid_resources_never_launch_qemu(self):
        for script in ("60-boot-live.sh", "70-boot-installed.sh"):
            for overrides in ({"MEOARCH_VM_CPUS": "0"}, {"MEOARCH_VM_CPUS": "2;id"},
                              {"MEOARCH_VM_MEMORY_MIB": "512"},
                              {"MEOARCH_VM_MEMORY_MIB": "99999"}):
                with self.subTest(script=script, overrides=overrides):
                    result = self.launch(script, overrides)
                    self.assertEqual(result.returncode, 2)
                    self.assertEqual(result.stdout, "")
