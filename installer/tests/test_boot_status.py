import importlib.util
from importlib.machinery import SourceFileLoader
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin" / "meo-boot-status"
SPEC = importlib.util.spec_from_loader(
    "meo_boot_status", SourceFileLoader("meo_boot_status", str(SCRIPT))
)
BOOT_STATUS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BOOT_STATUS)


class BootStatusTests(unittest.TestCase):
    def test_plymouth_client_is_not_called_when_daemon_is_absent(self):
        with tempfile.TemporaryDirectory() as temporary:
            pid_file = Path(temporary) / "plymouth" / "pid"
            with patch.object(BOOT_STATUS, "PLYMOUTH_PID_FILE", pid_file):
                with patch.object(BOOT_STATUS.subprocess, "run") as run:
                    BOOT_STATUS.run_plymouth_cmd("update", "--progress=95")
        run.assert_not_called()

    def test_plymouth_client_runs_when_daemon_pid_file_exists(self):
        with tempfile.TemporaryDirectory() as temporary:
            pid_file = Path(temporary) / "plymouth" / "pid"
            pid_file.parent.mkdir()
            pid_file.write_text("1234\n", encoding="utf-8")
            with patch.object(BOOT_STATUS, "PLYMOUTH_PID_FILE", pid_file):
                with patch.object(BOOT_STATUS.subprocess, "run") as run:
                    BOOT_STATUS.run_plymouth_cmd("update", "--progress=95")
        run.assert_called_once()
        self.assertEqual(run.call_args.kwargs["timeout"], BOOT_STATUS.PLYMOUTH_COMMAND_TIMEOUT_SECONDS)


if __name__ == "__main__":
    unittest.main()
