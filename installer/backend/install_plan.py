#!/usr/bin/env python3
"""Shared, non-secret MeoArch repository and package-install planning.

The QML installer, CLI and Archinstall generator consume this module. It is
purposefully declarative: it never mutates pacman.conf and never invokes
pacman, so it is safe to test on a developer machine.
"""
from __future__ import annotations

from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
from typing import Any

SUPPORTED_ARCHITECTURE = "x86_64"
PROFILES = {"recommended", "minimal", "custom"}
CHANNELS = {"stable", "beta"}


class PlanError(ValueError):
    pass


@dataclass(frozen=True)
class RepositoryPlan:
    channel: str
    mirror: str
    base_url: str
    repositories: tuple[str, ...]
    bootstrap_packages: tuple[str, ...]
    channel_package: str
    core_packages: tuple[str, ...]
    core_train_available: bool
    availability_message: str


@dataclass(frozen=True)
class PackagePlan:
    profile: str
    packages: tuple[str, ...]
    required: tuple[str, ...]


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


def _validate_catalog_contract(path: Path, catalog: dict[str, Any]) -> None:
    """Reject a shipped catalog when its release copy contract has drifted."""
    contract_path = path.with_name(path.stem + ".contract.json")
    if not contract_path.is_file():
        return
    contract = load_json(contract_path)
    expected = {
        "schemaVersion": 1,
        "catalogSchemaVersion": 2,
        "generation": catalog.get("generation"),
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
    }
    if contract != expected:
        raise PlanError("package catalog generation/hash contract does not match the release catalog")


def catalog_from(path: str | Path) -> dict[str, Any]:
    path = Path(path)
    catalog = load_json(path)
    if catalog.get("schemaVersion") != 2:
        raise PlanError("unsupported package catalog schema")
    if not isinstance(catalog.get("generation"), str) or not catalog["generation"]:
        raise PlanError("package catalog has no release generation")
    if catalog.get("architecture") != SUPPORTED_ARCHITECTURE:
        raise PlanError("package catalog does not support x86_64")
    if catalog.get("repositoryNames") != {"stable": "meo", "beta": "meo-beta"}:
        raise PlanError("package catalog has invalid repository names")
    if catalog.get("defaultChannel") != "beta":
        raise PlanError("the beta trial catalog must default to beta")
    if not isinstance(catalog.get("repositoryBaseUrl"), str) or not catalog["repositoryBaseUrl"].startswith("https://"):
        raise PlanError("package catalog has no HTTPS repository base URL")
    if catalog.get("bootstrapPackages") != ["meo-keyring", "meo-mirrorlist"]:
        raise PlanError("package catalog has invalid bootstrap packages")
    if catalog.get("channelPackages") != {
        "stable": "meo-channel-stable",
        "beta": "meo-channel-beta",
    }:
        raise PlanError("package catalog has invalid channel packages")
    availability = catalog.get("channelAvailability")
    if not isinstance(availability, dict) or set(availability) != CHANNELS:
        raise PlanError("package catalog has invalid channel availability")
    if not isinstance(catalog.get("officialPackages"), list):
        raise PlanError("package catalog has no official package set")
    packages = catalog.get("packages")
    if not isinstance(packages, dict) or not packages:
        raise PlanError("package catalog has no profile package metadata")
    _validate_catalog_contract(path, catalog)
    return catalog


def _closure(selected: set[str], catalog: dict[str, Any]) -> set[str]:
    packages = catalog["packages"]
    pending = list(selected)
    while pending:
        name = pending.pop()
        if name not in packages:
            raise PlanError(f"unknown Meo package selection: {name}")
        metadata = packages[name]
        if not isinstance(metadata, dict):
            raise PlanError(f"invalid package metadata for {name}")
        for dependency in metadata.get("requires", []):
            if not isinstance(dependency, str):
                raise PlanError(f"invalid package dependency for {name}")
            if dependency not in selected:
                selected.add(dependency)
                pending.append(dependency)
    return selected


def build_install_plan(
    config: dict[str, Any],
    catalog: dict[str, Any],
    architecture: str = SUPPORTED_ARCHITECTURE,
) -> InstallPlan:
    if architecture != SUPPORTED_ARCHITECTURE:
        raise PlanError(f"MeoArch package installation is unsupported on {architecture}")
    if config.get("schemaVersion", 2) != 2:
        raise PlanError("unsupported InstallConfig schemaVersion")
    channel = str(config.get("channel", catalog["defaultChannel"]))
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
    availability = catalog["channelAvailability"][channel]
    if not isinstance(availability, dict) or not isinstance(availability.get("coreTrainAvailable"), bool):
        raise PlanError(f"package catalog has invalid {channel} availability metadata")
    message = availability.get("message")
    if not isinstance(message, str) or not message:
        raise PlanError(f"package catalog has invalid {channel} availability message")
    repository = RepositoryPlan(
        channel=channel,
        mirror=mirror,
        base_url=catalog["repositoryBaseUrl"].rstrip("/"),
        repositories=repos,
        bootstrap_packages=tuple(catalog["bootstrapPackages"]),
        channel_package=catalog["channelPackages"][channel],
        core_packages=tuple(sorted(packages)),
        core_train_available=availability["coreTrainAvailable"],
        availability_message=message,
    )
    package = PackagePlan(profile, tuple(sorted(selected | {"meo-release"})), tuple(sorted(required)))
    return InstallPlan(2, architecture, repository, package)


def plan_as_dict(plan: InstallPlan) -> dict[str, Any]:
    return {
        "schemaVersion": plan.schema_version,
        "architecture": plan.architecture,
        "repository": {
            "channel": plan.repository.channel,
            "mirror": plan.repository.mirror,
            "baseUrl": plan.repository.base_url,
            "repositories": list(plan.repository.repositories),
            "bootstrapPackages": list(plan.repository.bootstrap_packages),
            "channelPackage": plan.repository.channel_package,
            "corePackages": list(plan.repository.core_packages),
            "coreTrainAvailable": plan.repository.core_train_available,
            "availabilityMessage": plan.repository.availability_message,
        },
        "package": {
            "profile": plan.package.profile,
            "packages": list(plan.package.packages),
            "required": list(plan.package.required),
        },
    }


def pacman_channel_fragment(plan: InstallPlan) -> str:
    sections = []
    for repo in plan.repository.repositories:
        sections += [
            f"[{repo}]",
            "SigLevel = Required TrustedOnly",
            "Include = /etc/pacman.d/meo-mirrorlist",
            "",
        ]
    return "\n".join(sections)


def write_json_atomic(path: str | Path, payload: dict[str, Any], mode: int = 0o600) -> None:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix(target.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.chmod(temporary, mode)
    temporary.replace(target)
