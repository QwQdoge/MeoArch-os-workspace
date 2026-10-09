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
import re
from pathlib import Path
from typing import Any

SUPPORTED_ARCHITECTURE = "x86_64"
PROFILES = {"recommended", "minimal", "custom"}
CHANNELS = {"stable", "beta"}
INPUT_METHOD_MODES = {"meo-managed", "self-managed"}
PACKAGE_NAME = re.compile(r"^[A-Za-z0-9@._+:-]{1,128}$")
INPUT_METHOD_CAPABILITY_ID = re.compile(r"^fcitx5\.[a-z0-9][a-z0-9._-]{0,63}$")
INSTALLED_SYSTEM_PACKAGES = {"meo-plasma-login-manager"}


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


@dataclass(frozen=True)
class ApplicationPlan:
    selected: tuple[str, ...]
    native_packages: tuple[str, ...]
    source: str


@dataclass(frozen=True)
class InputMethodPlan:
    """User intent only; package resolution belongs to the signed repo catalog."""

    mode: str
    framework: str
    engine_capabilities: tuple[str, ...]
    initial_engine: str


@dataclass(frozen=True)
class InstallPlan:
    schema_version: int
    architecture: str
    generation: str
    repository: RepositoryPlan
    package: PackagePlan
    applications: ApplicationPlan
    input_method: InputMethodPlan


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
    generation = catalog.get("generation")
    if not isinstance(generation, str) or not re.fullmatch(r"[0-9]{4}\.[0-9]{2}", generation):
        raise PlanError("package catalog has an invalid release generation")
    return catalog


def application_catalog_from(path: str | Path, generation: str | None = None) -> dict[str, Any]:
    catalog = load_json(path)
    if catalog.get("schemaVersion") != 1 or catalog.get("architecture") != SUPPORTED_ARCHITECTURE:
        raise PlanError("unsupported application catalog")
    if generation is not None and catalog.get("generation") != generation:
        raise PlanError("application and package catalogs have different generations")
    applications = catalog.get("applications")
    if not isinstance(applications, list) or not applications:
        raise PlanError("application catalog is empty")
    seen: set[str] = set()
    for application in applications:
        if not isinstance(application, dict):
            raise PlanError("application catalog entry must be an object")
        app_id = application.get("id")
        installer = application.get("installer")
        if not isinstance(app_id, str) or not app_id or app_id in seen:
            raise PlanError("application catalog contains an invalid or duplicate id")
        seen.add(app_id)
        if not isinstance(installer, dict) or installer.get("source") != "arch-official":
            raise PlanError(f"application {app_id} has an unsupported installer source")
        package = installer.get("package")
        if not isinstance(package, str) or not PACKAGE_NAME.fullmatch(package):
            raise PlanError(f"application {app_id} has an invalid package name")
        profiles = installer.get("profiles", [])
        if not isinstance(profiles, list) or any(profile not in PROFILES for profile in profiles):
            raise PlanError(f"application {app_id} has invalid profile defaults")
        if installer.get("tier") == "third-party" and profiles:
            raise PlanError(f"third-party application {app_id} must be opt-in")
    return catalog


def resolve_applications(config: dict[str, Any], catalog: dict[str, Any], profile: str) -> ApplicationPlan:
    by_id = {application["id"]: application for application in catalog["applications"]}
    requested = config.get("applications", [])
    if not isinstance(requested, list) or any(not isinstance(app_id, str) for app_id in requested):
        raise PlanError("applications must be a list of catalog ids")
    unknown = sorted(set(requested) - set(by_id))
    if unknown:
        raise PlanError(f"unknown application selection: {unknown[0]}")
    selected = set(requested)
    for app_id, application in by_id.items():
        if profile in application["installer"].get("profiles", []):
            selected.add(app_id)
    native_packages = {by_id[app_id]["installer"]["package"] for app_id in selected}
    return ApplicationPlan(tuple(sorted(selected)), tuple(sorted(native_packages)), "arch-official")


def resolve_input_method(config: dict[str, Any]) -> InputMethodPlan:
    """Validate input-method intent without resolving or installing packages.

    Package names and availability are deliberately outside the Installer plan.
    The transaction layer must resolve the selected capability IDs against the
    versioned, signed-repository-owned input-method capability catalog.
    """

    raw = config.get("inputMethod", {})
    if raw is None:
        raw = {}
    if not isinstance(raw, dict):
        raise PlanError("inputMethod must be an object")

    allowed_keys = {"mode", "framework", "engineCapabilities", "initialEngine"}
    unknown_keys = sorted(set(raw) - allowed_keys)
    if unknown_keys:
        raise PlanError(f"inputMethod contains an unsupported key: {unknown_keys[0]}")

    mode = raw.get("mode", "meo-managed")
    if not isinstance(mode, str) or mode not in INPUT_METHOD_MODES:
        raise PlanError("inputMethod.mode must be meo-managed or self-managed")

    framework_default = "fcitx5" if mode == "meo-managed" else ""
    framework = raw.get("framework", framework_default)
    if not isinstance(framework, str):
        raise PlanError("inputMethod.framework must be a string")

    engines = raw.get("engineCapabilities", [])
    if (not isinstance(engines, list)
            or len(engines) > 16
            or any(not isinstance(engine, str) or not INPUT_METHOD_CAPABILITY_ID.fullmatch(engine)
                   for engine in engines)):
        raise PlanError("inputMethod.engineCapabilities must be a bounded list of Fcitx capability IDs")
    if len(set(engines)) != len(engines):
        raise PlanError("inputMethod.engineCapabilities must not contain duplicates")

    initial_engine = raw.get("initialEngine", "")
    if not isinstance(initial_engine, str):
        raise PlanError("inputMethod.initialEngine must be a string")
    if initial_engine and initial_engine not in engines:
        raise PlanError("inputMethod.initialEngine must be one of engineCapabilities")

    if mode == "meo-managed":
        if framework != "fcitx5":
            raise PlanError("Meo-managed input method currently requires the fcitx5 framework")
    else:
        if framework or engines or initial_engine:
            raise PlanError(
                "self-managed input method cannot request a Meo-managed framework or engine capabilities"
            )

    return InputMethodPlan(mode, framework, tuple(engines), initial_engine)


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


def build_install_plan(config: dict[str, Any], catalog: dict[str, Any], architecture: str = SUPPORTED_ARCHITECTURE,
                       application_catalog: dict[str, Any] | None = None) -> InstallPlan:
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
        components = config.get("components")
        if not isinstance(components, list) or any(
                not isinstance(name, str) or not PACKAGE_NAME.fullmatch(name)
                for name in components):
            raise PlanError("custom components must be a list of package names")
        selected = set(components)
        if "meo-desktop" not in selected:
            raise PlanError("custom profile requires meo-desktop")
    else:
        selected = {name for name, metadata in packages.items() if profile in metadata.get("profiles", [])}

    # A standalone meo-desktop package must remain display-manager neutral so
    # an existing Arch/KDE installation only gains another session. The
    # MeoArch OS installer, however, owns the complete installed-system login
    # experience and therefore installs Meo Login explicitly for every profile.
    selected.update(INSTALLED_SYSTEM_PACKAGES)
    selected = _closure(selected, catalog)
    required = _closure({"meo-desktop", *INSTALLED_SYSTEM_PACKAGES}, catalog)

    mirror = str(config.get("mirror", "automatic"))
    if mirror != "automatic":
        raise PlanError("only official automatic mirror selection is currently supported")
    repos = ("meo",) if channel == "stable" else ("meo-beta", "meo")
    channel_package = catalog["channelPackages"][channel]
    repository = RepositoryPlan(channel, mirror, repos, tuple(catalog["bootstrapPackages"]), channel_package)
    package = PackagePlan(profile, tuple(sorted(selected | {"meo-release"})), tuple(sorted(required)))
    applications = (resolve_applications(config, application_catalog, profile)
                    if application_catalog is not None else ApplicationPlan((), (), "arch-official"))
    input_method = resolve_input_method(config)
    return InstallPlan(2, architecture, catalog["generation"], repository, package, applications, input_method)


def plan_as_dict(plan: InstallPlan) -> dict[str, Any]:
    return {
        "schemaVersion": plan.schema_version,
        "architecture": plan.architecture,
        "generation": plan.generation,
        "repository": {"channel": plan.repository.channel, "mirror": plan.repository.mirror,
                       "repositories": list(plan.repository.repositories),
                       "bootstrapPackages": list(plan.repository.bootstrap_packages),
                       "channelPackage": plan.repository.channel_package},
        "package": {"profile": plan.package.profile, "packages": list(plan.package.packages),
                    "required": list(plan.package.required)},
        "applications": {"selected": list(plan.applications.selected),
                         "nativePackages": list(plan.applications.native_packages),
                         "source": plan.applications.source},
        "inputMethod": {"mode": plan.input_method.mode,
                        "framework": plan.input_method.framework,
                        "engineCapabilities": list(plan.input_method.engine_capabilities),
                        "initialEngine": plan.input_method.initial_engine}
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
