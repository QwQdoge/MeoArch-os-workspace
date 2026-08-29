#!/usr/bin/env python3
"""Shared, non-secret MeoArch repository and package-install planning.

The QML installer, CLI and Archinstall generator consume this module.  It is
purposefully declarative: it never mutates pacman.conf and never invokes
pacman, so it is safe to test on a developer machine.
"""
from __future__ import annotations

from dataclasses import dataclass
import json
import os
from pathlib import Path
from typing import Any

SUPPORTED_ARCHITECTURE = "x86_64"
PROFILES = {"recommended", "minimal", "custom"}
CHANNELS = {"stable", "beta"}
PACKAGE_NAME = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@._+:-")

class PlanError(ValueError):
    pass

@dataclass(frozen=True)
class RepositoryPlan:
    channel: str
    mirror: str
    repositories: tuple[str, ...]
    bootstrap_packages: tuple[str, ...]
    channel_package: str

@dataclass(frozen=True)
class PackagePlan:
    profile: str
    packages: tuple[str, ...]
    required: tuple[str, ...]
    system_packages: tuple[str, ...]

@dataclass(frozen=True)
class InstallPlan:
    schema_version: int
    architecture: str
    repository: RepositoryPlan
    package: PackagePlan

def load_json(path: str | Path) -> dict[str, Any]:
    with Path(path).open(encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise PlanError("configuration must be a JSON object")
    return data

def load_config(path: str | Path) -> dict[str, Any]:
    path = Path(path)
    if path.suffix.lower() in {".yaml", ".yml"}:
        try:
            import yaml  # type: ignore
        except ImportError as error:
            raise PlanError("YAML config requires the python-yaml package in the live ISO") from error
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise PlanError("YAML configuration must be an object")
        return data
    return load_json(path)

def catalog_from(path: str | Path) -> dict[str, Any]:
    catalog = load_json(path)
    if catalog.get("schemaVersion") != 1:
        raise PlanError("unsupported package catalog schema")
    if catalog.get("architecture") != SUPPORTED_ARCHITECTURE:
        raise PlanError("package catalog does not support x86_64")
    return catalog

def application_catalog_from(path: str | Path) -> dict[str, Any]:
    catalog = load_json(path)
    applications = catalog.get("applications")
    if catalog.get("schemaVersion") != 1 or not isinstance(applications, dict):
        raise PlanError("unsupported application catalog schema")
    for app_id, metadata in applications.items():
        package = metadata.get("package") if isinstance(metadata, dict) else None
        if (not isinstance(app_id, str) or not app_id or not isinstance(package, str) or not package
                or any(char not in PACKAGE_NAME for char in package)):
            raise PlanError("application catalog contains an invalid official package")
    return catalog

def _system_packages(config: dict[str, Any], application_catalog: dict[str, Any] | None, profile: str) -> tuple[str, ...]:
    if application_catalog is None:
        if config.get("applications"):
            raise PlanError("application selections require the official application catalog")
        return ()
    applications = application_catalog["applications"]
    selected = set(str(value) for value in config.get("applications", []))
    if profile == "recommended":
        selected.update(app_id for app_id, metadata in applications.items()
                        if metadata.get("defaultProfile") == "recommended")
    unknown = selected - set(applications)
    if unknown:
        raise PlanError("unknown or non-official installer application selection")
    return tuple(sorted({applications[app_id]["package"] for app_id in selected}))

def _closure(selected: set[str], catalog: dict[str, Any]) -> set[str]:
    packages = catalog.get("packages", {})
    pending = list(selected)
    while pending:
        name = pending.pop()
        if name not in packages:
            raise PlanError(f"unknown Meo package selection: {name}")
        for dependency in packages[name].get("requires", []):
            if dependency not in selected:
                selected.add(dependency)
                pending.append(dependency)
    return selected

def build_install_plan(
    config: dict[str, Any],
    catalog: dict[str, Any],
    architecture: str = SUPPORTED_ARCHITECTURE,
    application_catalog: dict[str, Any] | None = None,
) -> InstallPlan:
    if architecture != SUPPORTED_ARCHITECTURE:
        raise PlanError(f"MeoArch package installation is unsupported on {architecture}")
    if config.get("schemaVersion", 2) != 2:
        raise PlanError("unsupported InstallConfig schemaVersion")
    channel = str(config.get("channel", "stable"))
    if channel not in CHANNELS:
        raise PlanError("channel must be stable or beta")
    profile = str(config.get("profile", "recommended"))
    if profile not in PROFILES:
        raise PlanError("profile must be recommended, minimal or custom")
    packages = catalog["packages"]
    if profile == "custom":
        selected = {str(name) for name in config.get("components", [])}
        if "meo-desktop" not in selected:
            raise PlanError("custom profile requires meo-desktop")
    else:
        selected = {name for name, metadata in packages.items() if profile in metadata.get("profiles", [])}
    selected = _closure(selected, catalog)
    required = _closure({"meo-desktop"}, catalog)
    mirror = str(config.get("mirror", "automatic"))
    if mirror != "automatic":
        raise PlanError("only official automatic mirror selection is currently supported")
    repos = ("meo",) if channel == "stable" else ("meo-beta", "meo")
    channel_package = catalog["channelPackages"][channel]
    repository = RepositoryPlan(channel, mirror, repos, tuple(catalog["bootstrapPackages"]), channel_package)
    package = PackagePlan(
        profile,
        tuple(sorted(selected | {"meo-release"})),
        tuple(sorted(required)),
        _system_packages(config, application_catalog, profile),
    )
    return InstallPlan(2, architecture, repository, package)

def plan_as_dict(plan: InstallPlan) -> dict[str, Any]:
    return {
        "schemaVersion": plan.schema_version,
        "architecture": plan.architecture,
        "repository": {"channel": plan.repository.channel, "mirror": plan.repository.mirror,
                       "repositories": list(plan.repository.repositories),
                       "bootstrapPackages": list(plan.repository.bootstrap_packages),
                       "channelPackage": plan.repository.channel_package},
        "package": {"profile": plan.package.profile, "packages": list(plan.package.packages),
                    "required": list(plan.package.required), "systemPackages": list(plan.package.system_packages)}
    }

def pacman_channel_fragment(plan: InstallPlan) -> str:
    sections = []
    for repo in plan.repository.repositories:
        sections += [f"[{repo}]", "SigLevel = Required TrustedOnly", "Include = /etc/pacman.d/meo-mirrorlist", ""]
    return "\n".join(sections)

def write_json_atomic(path: str | Path, payload: dict[str, Any], mode: int = 0o600) -> None:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix(target.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.chmod(temporary, mode)
    temporary.replace(target)
