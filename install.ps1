param([string]$ProfileDir)
$ErrorActionPreference = "Stop"

$FirefoxDir = Join-Path $env:APPDATA "Mozilla\Firefox"
$Pref = 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

if (-not $ProfileDir) {
    $Line = Get-Content (Join-Path $FirefoxDir "installs.ini") | Where-Object { $_ -like "Default=*" } | Select-Object -First 1
    $ProfileDir = Join-Path $FirefoxDir ($Line -replace "^Default=", "")
}

if (-not (Test-Path $ProfileDir -PathType Container)) {
    Write-Error "Profile not found: $ProfileDir"
}

$Source = Join-Path $PSScriptRoot "chrome\userChrome.css"
New-Item -ItemType Directory -Force (Join-Path $PSScriptRoot "chrome") | Out-Null
$Css = @('@charset "UTF-8";')
# -Encoding UTF8 is required, because Windows PowerShell 5.1 reads files as ANSI by default.
foreach ($Line in Get-Content -Encoding UTF8 (Join-Path $PSScriptRoot "folders.conf")) {
    if ($Line -eq "" -or $Line.StartsWith("#")) { continue }
    # Split at the last "=", because folder names may contain "=" but colors never do.
    $i = $Line.LastIndexOf("=")
    $Name = $Line.Substring(0, $i) -replace '([\\"])', '\$1'
    $Color = $Line.Substring($i + 1).Trim()
    $Css += ".bookmark-item[container][label=""$Name""] {`n  background-color: ${Color}55 !important;`n}"
}
Set-Content -Encoding UTF8 $Source $Css
Write-Host "Generated: $Source"

$ChromeDir = Join-Path $ProfileDir "chrome"
$Target = Join-Path $ChromeDir "userChrome.css"
New-Item -ItemType Directory -Force $ChromeDir | Out-Null

# Copied instead of symlinked, because symlinks on Windows need admin rights or Developer Mode.
# Not overwritten without the marker, because the file may contain the user's own customizations.
# A marker is used instead of comparing contents, because an old copy differs from the edited repo file.
$Marker = Join-Path $ChromeDir ".clean-bookmarks"
if ((Test-Path $Target) -and -not (Test-Path $Marker)) {
    Write-Error "A file not created by this script already exists: $Target`nMove it away and run again."
}
Copy-Item -Force $Source $Target
New-Item -ItemType File -Force $Marker | Out-Null
Write-Host "Copied: $Source -> $Target"

$UserJs = Join-Path $ProfileDir "user.js"
if (-not ((Test-Path $UserJs) -and (Select-String -Quiet -SimpleMatch $Pref $UserJs))) {
    Add-Content $UserJs $Pref
}
Write-Host "Pref enabled in: $UserJs"

Write-Host "Restart Firefox to apply."
