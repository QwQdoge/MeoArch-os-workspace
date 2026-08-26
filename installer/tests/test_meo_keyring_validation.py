import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]


class MeoKeyringValidationTests(unittest.TestCase):
    def test_missing_bootstrap_payload_fails_closed_before_disk_work(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [sys.executable, ROOT / "backend/validate_meo_keyring.py", directory],
                capture_output=True,
                text=True,
            )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing/non-empty", result.stderr)


if __name__ == "__main__":
    unittest.main()
