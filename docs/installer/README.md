# MeoArch Installer Documentation

This folder contains the public-facing installer design and runtime
documentation.

- `INSTALLER_SPEC.md` describes the product goals, user flow, safety rules, and
  future backend boundaries.
- `CAGE_INSTALLER.md` describes how the current framework runs inside the live
  ISO through Cage and systemd.
- `INSTALLER_SPEC.zh_cn.md` is the Simplified Chinese version of the installer
  specification.
- `CAGE_INSTALLER.zh_cn.md` is the Simplified Chinese version of the Cage runtime
  document.
- `PRODUCTION_ARCHITECTURE.md` records the production/preview boundary, shared
  Meo.System dependency, installation-plan flow, disk safety policy, secret
  lifecycle, and current explicitly unavailable capabilities.

Read `INSTALLER_SPEC.md` first if you are reviewing the installer experience.
Read `CAGE_INSTALLER.md` first if you are integrating or debugging the live ISO
runtime.
