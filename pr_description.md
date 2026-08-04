🧪 Add tests for hardware lspci errors

🎯 **What:** The testing gap addressed was testing the `lspci_devices` function in `installer/backend/hardware.py` when `subprocess.run` raises `FileNotFoundError` (missing command) or `subprocess.SubprocessError` (timeout).
📊 **Coverage:** The tests now cover error conditions, specifically the missing `lspci` command and the `lspci` command timing out.
✨ **Result:** The test coverage for the hardware module is improved and the fallback behavior of `lspci_devices` returning an empty list upon `subprocess.run` errors is verified.
