param(
    [string]$QtBin = $env:QT_BIN_DIR,
    [string]$QtRoot = $env:QT_ROOT_DIR,
    [switch]$EnableSystemActions,
    [switch]$EnableArchinstallPreflight,
    [switch]$Wait
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$MainQml = Join-Path $RepoRoot "installer\qml\Main.qml"
$InstallerQmlDir = Join-Path $RepoRoot "installer\qml"

function Find-QmlRuntime {
    param(
        [string]$PreferredQtBin,
        [string]$PreferredQtRoot
    )

    if (-not [string]::IsNullOrWhiteSpace($PreferredQtBin)) {
        $candidate = Join-Path $PreferredQtBin "qml.exe"
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }

    $fromPath = Get-Command qml.exe -ErrorAction SilentlyContinue
    if ($fromPath) { return $fromPath.Source }

    $roots = @()
    if (-not [string]::IsNullOrWhiteSpace($PreferredQtRoot)) {
        $roots += $PreferredQtRoot
    }
    if (Test-Path -LiteralPath "C:\Qt") {
        $roots += "C:\Qt"
    }

    foreach ($root in ($roots | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        $candidate = Get-ChildItem -LiteralPath $root -Filter qml.exe -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.DirectoryName -match '[\\/]bin$' } |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($candidate) { return $candidate.FullName }
    }

    throw "qml.exe was not found. Set QT_BIN_DIR, put qml.exe on PATH, or set QT_ROOT_DIR to the Qt installation root."
}

$QmlExe = Find-QmlRuntime $QtBin $QtRoot
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
