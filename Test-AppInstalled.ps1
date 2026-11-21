# Test-AppInstalled.ps1
# Intune detection script: checks whether 7-Zip or Google Chrome is installed.
# Returns exit code 0 when the app is found (Intune treats this as "installed"),
# and exit code 1 when it is not found (Intune treats this as "not installed").
#
# Usage in Intune: App > Detection rules > Use a custom detection script,
# upload this file. Set the app to 7-Zip or Chrome and match $AppName below.
# Run locally to test:  .\Test-AppInstalled.ps1 -AppName "7-Zip"
#                       .\Test-AppInstalled.ps1 -AppName "Google Chrome"
#
# Checks both the 64-bit and 32-bit uninstall registry keys, plus the
# default install folders, so it works whether the app was installed
# per-machine or per-user.

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("7-Zip", "Google Chrome")]
    [string]$AppName
)

$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

$found = $false
foreach ($key in $UninstallKeys) {
    if (-not (Test-Path $key)) { continue }
    $apps = Get-ChildItem $key -ErrorAction SilentlyContinue |
        Get-ItemProperty -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$AppName*" }
    if ($apps) {
        foreach ($app in $apps) {
            Write-Host "Found: $($app.DisplayName) ($($app.DisplayVersion)) in $key"
        }
        $found = $true
    }
}

if (-not $found) {
    $ProgramPaths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe",
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    )
    $matching = $ProgramPaths | Where-Object {
        ($_ -like "*7-Zip*" -and $AppName -eq "7-Zip") -or
        ($_ -like "*Chrome*" -and $AppName -eq "Google Chrome")
    } | Where-Object { Test-Path $_ }
    if ($matching) {
        foreach ($path in $matching) { Write-Host "Found: $path" }
        $found = $true
    }
}

if ($found) {
    Write-Host "$AppName is installed."
    exit 0
} else {
    Write-Host "$AppName is NOT installed."
    exit 1
}
