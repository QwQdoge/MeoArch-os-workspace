param(
    [ValidateSet("install", "update", "upgrade", "verify", "uninstall")]
    [string]$Action = "install",
    [string]$Version = $env:MEO_UI_VERSION,
    [string]$Prefix = $env:MEO_UI_PREFIX,
    [string]$FontDir = $env:MEO_UI_FONT_DIR,
    [string]$QmlSource = $env:MEO_UI_QML_SOURCE,
    [string]$FontSource = $env:MEO_UI_FONT_SOURCE,
    [switch]$Yes
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Version)) { $Version = "0.3.1" }
if ([string]::IsNullOrWhiteSpace($Prefix)) { $Prefix = Join-Path $env:LOCALAPPDATA "MeoUI" }
if ([string]::IsNullOrWhiteSpace($FontDir)) { $FontDir = Join-Path $Prefix "fonts" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ((Test-Path (Join-Path $ScriptDir "qml\Meo\UI")) -or (Test-Path (Join-Path $ScriptDir "components"))) {
    $PackageRoot = $ScriptDir
} else {
    $PackageRoot = Split-Path -Parent $ScriptDir
}

$QmlTarget = Join-Path $Prefix "qml\Meo\UI"
$QmlCompatTarget = Join-Path $Prefix "qml\MeoUI"
$VersionFile = Join-Path $Prefix "VERSION"
$ManifestFile = Join-Path $Prefix "install-manifest.txt"

function Confirm-Action($Prompt) {
    if ($Yes) { return $true }
    $answer = Read-Host "$Prompt [y/N]"
    return $answer -in @("y", "Y", "yes", "YES")
}

function Compare-VersionString($A, $B) {
    if ($A -eq $B) { return 0 }
    try {
        return ([version]$A).CompareTo([version]$B)
    } catch {
        return [string]::Compare($A, $B, $true)
    }
}

function Copy-Directory($Source, $Destination) {
    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Remove-Path($Path) {
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function Sanitize-Qmldir($Path) {
    $tempPath = "$Path.tmp"
    Get-Content -LiteralPath $Path |
        Where-Object { $_ -notmatch '^(linktarget|optional plugin|classname|prefer)\s' } |
        Set-Content -LiteralPath $tempPath -Encoding UTF8
    Move-Item -LiteralPath $tempPath -Destination $Path -Force
}

function New-Qmldir($Root) {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("module MeoUI")
    $lines.Add("singleton MeoTheme 1.0 MeoTheme.qml")
    foreach ($subdir in @("components", "widgets", "patterns", "showcase")) {
        $dir = Join-Path $Root $subdir
        if (Test-Path -LiteralPath $dir) {
            Get-ChildItem -LiteralPath $dir -Recurse -Filter *.qml |
                Sort-Object FullName |
                ForEach-Object {
                    $relative = [IO.Path]::GetRelativePath($Root, $_.FullName).Replace("\", "/")
                    $typeName = [IO.Path]::GetFileNameWithoutExtension($_.Name)
                    $lines.Add("$typeName 1.0 $relative")
                }
        }
    }
    $lines.Add("depends QtQuick")
    $lines | Set-Content -LiteralPath (Join-Path $Root "qmldir") -Encoding UTF8
}

function Resolve-Sources {
    if ([string]::IsNullOrWhiteSpace($script:QmlSource)) {
        $runtimeQml = Join-Path $PackageRoot "qml\Meo\UI"
        $buildQml = Join-Path $PackageRoot "out\build\showcase\MeoUI"
        if (Test-Path -LiteralPath $runtimeQml) {
            $script:QmlSource = $runtimeQml
        } elseif (Test-Path -LiteralPath $buildQml) {
            $script:QmlSource = $buildQml
        } elseif ((Test-Path (Join-Path $PackageRoot "MeoTheme.qml")) -and (Test-Path (Join-Path $PackageRoot "components"))) {
            $script:QmlSource = $PackageRoot
        }
    }

    if ([string]::IsNullOrWhiteSpace($script:FontSource)) {
        $runtimeFonts = Join-Path $PackageRoot "fonts"
        $qmlFonts = Join-Path $script:QmlSource "assets\fonts"
        $sourceFonts = Join-Path $PackageRoot "assets\fonts"
        if (Test-Path -LiteralPath $runtimeFonts) {
            $script:FontSource = $runtimeFonts
        } elseif (Test-Path -LiteralPath $qmlFonts) {
            $script:FontSource = $qmlFonts
        } elseif (Test-Path -LiteralPath $sourceFonts) {
            $script:FontSource = $sourceFonts
        }
    }
}

function Test-MeoUIRuntime {
    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($path in @(
        $VersionFile,
        (Join-Path $QmlTarget "MeoTheme.qml"),
        (Join-Path $QmlTarget "qmldir"),
        $QmlCompatTarget
    )) {
        if (-not (Test-Path -LiteralPath $path)) { $missing.Add($path) }
    }
    foreach ($font in @("MaterialSymbolsRounded.ttf", "Roboto-Regular.ttf", "Roboto-Medium.ttf", "Roboto-Bold.ttf", "Comfortaa-Bold.ttf")) {
        $fontPath = Join-Path $FontDir $font
        if (-not (Test-Path -LiteralPath $fontPath)) { $missing.Add($fontPath) }
    }
    if ($missing.Count -gt 0) {
        $missing | ForEach-Object { Write-Error "missing: $_" }
        exit 1
    }
    Write-Host "MeoUI runtime verified."
    Write-Host "Version: $((Get-Content -LiteralPath $VersionFile -Raw).Trim())"
    Write-Host "QML import path: $(Join-Path $Prefix 'qml')"
    Write-Host "Fonts: $FontDir"
}

function Install-MeoUIRuntime {
    Resolve-Sources
    if (-not (Test-Path -LiteralPath $QmlSource)) { throw "QML source directory not found" }
    if (-not (Test-Path -LiteralPath $FontSource)) { throw "font source directory not found" }

    if (Test-Path -LiteralPath $VersionFile) {
        $installedVersion = (Get-Content -LiteralPath $VersionFile -Raw).Trim()
        $cmp = Compare-VersionString $Version $installedVersion
        if ($Action -eq "upgrade" -and $cmp -le 0) {
            throw "upgrade requires a newer version than installed $installedVersion"
        }
        if ($Action -eq "install") {
            if ($cmp -lt 0) {
                if (-not (Confirm-Action "Installed version is $installedVersion; requested $Version is older. Downgrade?")) { return }
            } elseif ($cmp -eq 0) {
                if (-not (Confirm-Action "MeoUI runtime $Version is already installed. Reinstall it?")) { return }
            } else {
                if (-not (Confirm-Action "Upgrade MeoUI runtime from $installedVersion to $Version?")) { return }
            }
        } elseif ($Action -eq "update") {
            if (-not (Confirm-Action "Update MeoUI runtime at $Prefix to $Version?")) { return }
        } elseif ($Action -eq "upgrade") {
            if (-not (Confirm-Action "Upgrade MeoUI runtime from $installedVersion to $Version?")) { return }
        }
    } elseif ((Test-Path -LiteralPath $QmlTarget) -or (Test-Path -LiteralPath $QmlCompatTarget) -or (Test-Path -LiteralPath $FontDir)) {
        if (-not (Confirm-Action "Existing MeoUI files were found without a version marker. Overwrite them?")) { return }
    }

    New-Item -ItemType Directory -Force -Path (Join-Path $Prefix "qml\Meo") | Out-Null
    New-Item -ItemType Directory -Force -Path $FontDir | Out-Null
    Copy-Directory $QmlSource $QmlTarget
    Copy-Directory $FontSource $FontDir
    Remove-Path (Join-Path $QmlTarget "libmeoui_moduleplugin.a")
    Remove-Path (Join-Path $QmlTarget "meoui_module_qml_module_dir_map.qrc")

    $qmldir = Join-Path $QmlTarget "qmldir"
    if (Test-Path -LiteralPath $qmldir) {
        Sanitize-Qmldir $qmldir
    } else {
        New-Qmldir $QmlTarget
    }

    Copy-Directory $QmlTarget $QmlCompatTarget
    $Version | Set-Content -LiteralPath $VersionFile -Encoding UTF8
    @($VersionFile, $QmlTarget, $QmlCompatTarget, $FontDir) | Set-Content -LiteralPath $ManifestFile -Encoding UTF8
    Test-MeoUIRuntime
}

function Uninstall-MeoUIRuntime {
    if ((-not (Test-Path -LiteralPath $Prefix)) -and (-not (Test-Path -LiteralPath $FontDir))) {
        Write-Host "MeoUI runtime is not installed."
        return
    }
    if (-not (Confirm-Action "Remove MeoUI runtime from $Prefix and fonts from $FontDir?")) { return }
    Remove-Path $QmlCompatTarget
    Remove-Path $QmlTarget
    Remove-Path (Join-Path $Prefix "qml\Meo")
    Remove-Path (Join-Path $Prefix "qml")
    Remove-Path $VersionFile
    Remove-Path $ManifestFile
    Remove-Path $FontDir
    if (Test-Path -LiteralPath $Prefix) {
        $remaining = Get-ChildItem -LiteralPath $Prefix -Force -ErrorAction SilentlyContinue
        if (-not $remaining) { Remove-Item -LiteralPath $Prefix -Force }
    }
    Write-Host "MeoUI runtime uninstalled."
}

switch ($Action) {
    "install" { Install-MeoUIRuntime }
    "update" { Install-MeoUIRuntime }
    "upgrade" { Install-MeoUIRuntime }
    "verify" { Test-MeoUIRuntime }
    "uninstall" { Uninstall-MeoUIRuntime }
}
