import stat
import unittest
from pathlib import Path


PROFILE_ROOT = Path(__file__).parents[2] / "meoarch-os" / "airootfs"
LOCAL_WRAPPER = PROFILE_ROOT / "usr/local/bin/archinstall"
SYSTEM_WRAPPER = PROFILE_ROOT / "usr/bin/archinstall"


class ArchinstallWrapperPathTests(unittest.TestCase):
    def test_both_live_archinstall_paths_are_wrapped_and_executable(self):
        self.assertTrue(LOCAL_WRAPPER.is_file())
        self.assertTrue(SYSTEM_WRAPPER.is_file())
        self.assertTrue(LOCAL_WRAPPER.stat().st_mode & stat.S_IXUSR)
        self.assertTrue(SYSTEM_WRAPPER.stat().st_mode & stat.S_IXUSR)
        self.assertEqual(LOCAL_WRAPPER.read_text(encoding="utf-8"),
                         SYSTEM_WRAPPER.read_text(encoding="utf-8"))

    def test_wrapper_calls_archinstall_module_without_executable_recursion(self):
        source = SYSTEM_WRAPPER.read_text(encoding="utf-8")
        self.assertIn('return [str(REAL_PYTHON), "-m", "archinstall", *argv]', source)
        self.assertNotIn('Path("/usr/bin/archinstall")', source)


if __name__ == "__main__":
    unittest.main()
