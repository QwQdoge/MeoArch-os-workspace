# Release Validation

`v0.1.0-alpha` is ready only after one evidence-backed run proves:

1. Release components and the shared `libmeoui.so.0` runtime build.
2. A real ISO builds and passes structural inspection.
3. The ISO boots through OVMF UEFI into the intended live graphical session.
4. The installer launches and all 12 pages remain functional.
5. Installation completes on the disposable qcow2 disk.
6. The ISO is detached and that disk boots independently.
7. A fresh user's first Plasma login loads Meo Desktop without duplicate panels.
8. Shelf, launcher, task manager, tray, clock, wallpaper, Settings and an
   application-launch workflow work.
9. OmniStore records only a versioned, allowlisted provisioning intent; it does
   not claim OmniStore was installed.
10. Logs, screenshots, package lists, checksums, VM configuration and baseline
    performance data are archived in one test-run directory.

Use `scripts/acceptance/run-all.sh` for CI-friendly build and inspection stages.
The report deliberately leaves VM interaction stages BLOCKED until they are
actually observed. Full PASS must never be inferred from dependency resolution,
QML rendering, target-root simulation or a Live ISO boot alone.
