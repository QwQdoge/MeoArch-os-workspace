# Meo product identity

This document freezes the public product identity for the current MeoArch release train.
New user-facing names, package descriptions, desktop metadata, documentation, and support text must follow this contract.

## Brand hierarchy

**MEO = Modern · Expressive · Open.**

| Scope | Canonical public name | Use |
| --- | --- | --- |
| Product family / brand | **Meo** | Umbrella brand for first-party software and design language |
| Operating system / distribution | **MeoArch** | OS, ISO, Live environment, distribution releases and meoarch.org infrastructure |
| Desktop experience / session | **Meo Desktop** | Desktop session, shell, look-and-feel and desktop integration |
| Settings | **Meo Settings** | System settings application |
| Installer | **Meo Installer** | Graphical MeoArch installer |
| Repair | **Meo Repair** | Repair and recovery application |
| Account | **Meo Account** | Shared account and credential-control application |
| AI | **Meo AI** | User-facing AI assistant |
| Login | **Meo Login** | Login/display-manager experience |
| Store | **OmniStore** | Application store product name |

## Naming rules

1. Use **MeoArch** when the subject is the operating system or distribution itself: the ISO, Live environment, release channel, package archive, system installation target, or meoarch.org infrastructure.
2. Use **Meo** for first-party application and experience names. Do not prefix application names with `MeoArch`.
3. Use **Meo Desktop** for the desktop product. KDE Plasma is an upstream platform and may be credited in descriptions, but `KDE`, `Plasma`, or `Plasma Desktop` is not the Meo product name.
4. User-visible login text uses **Meo Login**. Upstream-compatible implementation identifiers such as `plasmalogin` may remain internally where changing them would break PAM, systemd, configuration, translation, or upstream compatibility.
5. Existing stable technical identifiers are not renamed only for cosmetic consistency during the release freeze. This includes executable names, environment variables, D-Bus interfaces, desktop IDs, configuration paths and ABI-visible service names that already have consumers.
6. New Meo-owned desktop/application IDs should use the `org.meo.*` namespace and prefer lower-case application IDs where the surrounding platform permits it. Existing historical IDs may remain as compatibility identifiers until a planned migration exists.
7. `QCoreApplication`/`QGuiApplication` organization identifiers may remain `MeoArch` where changing them would move existing settings or state. The application display name still follows this document.
8. Package names remain lowercase `meo-*`. A package may retain an upstream-derived technical name when it provides/replaces an upstream package; its `pkgdesc` must still use the canonical Meo product name.

## Public wording examples

Preferred:

- `Meo Installer installs MeoArch.`
- `Meo Settings configures your MeoArch system.`
- `Meo Desktop is powered by KDE Plasma 6.`
- `Meo Login is the login experience shipped by MeoArch.`

Avoid:

- `MeoArch Installer`
- `MeoArch Settings`
- `MeoArch Desktop (Wayland)` as the session name
- `Plasma Login` as the public product name
- `KDE Desktop` as the Meo desktop product name

## Signing identity

The package archive is distribution infrastructure, so the canonical public signing identity for this release is:

`MeoArch Package Archive <packages@meoarch.org>`

The trusted primary key fingerprint for the current release train is:

`ACCF 58C0 05D4 67A0 C863 3806 F302 FD51 C406 16AA`

Signing subkeys may rotate under this trusted primary key according to the key-management runbook. The offline primary private key must never be committed to source control or CI.

The signing UID and trusted primary fingerprint are release identity, not general application branding. Do not regenerate or rename the archive key merely to replace `MeoArch` with `Meo`.

## Release-freeze compatibility boundary

The following may intentionally keep older or upstream-compatible internal names in this release:

- `plasmalogin` systemd/PAM/configuration/runtime identifiers
- the `meo-plasma-login-manager` package name and its `provides/conflicts/replaces` relationship
- existing D-Bus names such as `org.meo.Accounts1`
- existing application IDs such as `org.meo.Accounts.Settings`
- existing `MEOARCH_*` installer environment variables and `meoarch-*` executable/resource names
- application organization identifiers used for persisted settings

These names must not be presented as competing public product brands. Any future migration must include compatibility aliases, upgrade behavior, tests, and an explicit removal window.