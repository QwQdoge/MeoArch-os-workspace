#!/usr/bin/env python3
"""Fail closed when release-facing Meo product identity drifts.

This is intentionally narrower than a repository-wide string ban. MeoArch is
still the correct name for the operating system and distribution, and several
MEOARCH_* / meoarch-* identifiers are stable compatibility interfaces.
"""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


class IdentityError(RuntimeError):
    pass


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise IdentityError(f"missing release identity surface: {relative}")
    return path.read_text(encoding="utf-8")


def require(relative: str, needle: str) -> None:
    text = read(relative)
    if needle not in text:
        raise IdentityError(f"{relative}: missing canonical identity {needle!r}")


def reject(relative: str, needle: str) -> None:
    text = read(relative)
    if needle in text:
        raise IdentityError(f"{relative}: legacy public identity remains: {needle!r}")


def main() -> int:
    # Installer: Meo is the application; MeoArch is the OS being installed.
    require("installer/app/main.cpp", 'QStringLiteral("Meo Installer")')
    require("installer/app/main.cpp", 'QStringLiteral("Meo Repair")')
    require("installer/qml/Main.qml", 'title: qsTr("Meo Installer")')
    reject("installer/qml/Main.qml", 'title: qsTr("MeoArch Installer")')

    # Repair: source package and the independently staged Live ISO copy must
    # stay identical in public naming. The large QML source still contains a
    # historical translated source key; app/main.cpp deliberately overrides
    # the runtime title in both supported UI languages.
    require("repair/app/main.cpp", 'QCoreApplication::setApplicationName(QStringLiteral("Meo Repair"))')
    require("repair/app/main.cpp", 'QStringLiteral("Meo 修复")')
    require("repair/app/main.cpp", 'rootObject->setProperty("title", repairWindowTitle(activeUiLanguage))')
    require("repair/data/org.meo.repair.desktop", "Name=Meo Repair")
    require("repair/data/org.meo.repair.desktop", "Name[zh_CN]=Meo 修复")
    reject("repair/data/org.meo.repair.desktop", "Name=MeoArch Quick Repair")

    live_entry = "meoarch-os/airootfs/usr/share/applications/org.meo.repair.desktop"
    require(live_entry, "Name=Meo Repair")
    require(live_entry, "Name[zh_CN]=Meo 修复")
    reject(live_entry, "Name=MeoArch Quick Repair")

    # The policy itself is part of the release contract.
    require("docs/product-identity.md", "MEO = Modern · Expressive · Open")
    require("docs/product-identity.md", "**Meo Desktop**")
    require("docs/product-identity.md", "**Meo Login**")
    require("docs/product-identity.md", "MeoArch Package Archive <packages@meoarch.org>")

    print("product identity check passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except IdentityError as exc:
        print(f"product identity check failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
