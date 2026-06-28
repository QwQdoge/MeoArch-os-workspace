param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$Config = "Release",
    [string]$BuildDir = "out/build/showcase",
    [string]$InstallDir = "out/install/showcase",
    [string]$QtPrefixPath = "",
    [switch]$Install,
    [switch]$Run
)

$ErrorActionPreference = "Stop"

$SourceDir = Split-Path -Parent $PSScriptRoot
$BuildPath = if ([System.IO.Path]::IsPathRooted($BuildDir)) { $BuildDir } else { Join-Path $SourceDir $BuildDir }
$InstallPath = if ([System.IO.Path]::IsPathRooted($InstallDir)) { $InstallDir } else { Join-Path $SourceDir $InstallDir }

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw "cmake was not found on PATH. Install CMake and Qt, or run this from a Qt developer shell."
}

$configureArgs = @("-S", $SourceDir, "-B", $BuildPath, "-DCMAKE_BUILD_TYPE=$Config")
if ($QtPrefixPath -ne "") {
    $configureArgs += "-DCMAKE_PREFIX_PATH=$QtPrefixPath"
}

cmake @configureArgs
cmake --build $BuildPath --config $Config --target MeoShowcaseDemo

if ($Install) {
    cmake --install $BuildPath --config $Config --prefix $InstallPath
}

if ($Run) {
    $candidates = @(
        (Join-Path $BuildPath $Config "MeoShowcaseDemo.exe"),
        (Join-Path $BuildPath "MeoShowcaseDemo.exe")
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) {
        throw "Could not find MeoShowcaseDemo.exe in $BuildPath"
    }
    & $exe
}
