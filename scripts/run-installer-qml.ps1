param(
    [string]$QtBin = $env:QT_BIN_DIR,
    [switch]$EnableSystemActions,
    [switch]$EnableArchinstallPreflight,
    [switch]$Wait
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$MainQml = Join-Path $RepoRoot "installer\qml\Main.qml"
$InstallerQmlDir = Join-Path $RepoRoot "installer\qml"

function Find-QmlRuntime {
    param([string]$PreferredQtBin)

    if (-not [string]::IsNullOrWhiteSpace($PreferredQtBin)) {
        $candidate = Join-Path $PreferredQtBin "qml.exe"
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }

    $fromPath = Get-Command qml.exe -ErrorAction SilentlyContinue
    if ($fromPath) { return $fromPath.Source }

    foreach ($path in @(
        "C:\Qt\6.11.1\mingw_64\bin\qml.exe",
        "C:\Qt\6.10.0\mingw_64\bin\qml.exe",
        "C:\Qt\6.9.0\mingw_64\bin\qml.exe",
        "C:\Qt\6.8.0\mingw_64\bin\qml.exe"
    )) {
        if (Test-Path -LiteralPath $path) { return $path }
    }

    throw "qml.exe was not found. Set QT_BIN_DIR or pass -QtBin C:\Path\To\Qt\bin."
}

$QmlExe = Find-QmlRuntime $QtBin
$QtBinDir = Split-Path -Parent $QmlExe
$env:PATH = "$QtBinDir;$env:PATH"

$QmlArgs = @("-I", $InstallerQmlDir, $MainQml)
if ($EnableSystemActions) {
    $QmlArgs += @("--", "--enable-system-actions")
}

if ($EnableArchinstallPreflight) {
    Write-Warning "The Windows QML preview does not run the Linux archinstall preflight helper. Test that flag through installer/bin/meoarch-installer under Linux/WSL or the live ISO."
}

if ($Wait) {
    & $QmlExe @QmlArgs
} else {
    $process = Start-Process -FilePath $QmlExe -ArgumentList $QmlArgs -WorkingDirectory $RepoRoot -PassThru
    Start-Sleep -Seconds 1
    if ($process.HasExited) {
        throw "qml.exe exited early with code $($process.ExitCode). Run with -Wait to see console output."
    }
    Write-Host "MeoArch Installer QML is running. PID: $($process.Id)"
}
