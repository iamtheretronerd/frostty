$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.frostty"
$BinDir = "$InstallDir\bin"

Write-Host "`nUninstalling Frostty..." -ForegroundColor Cyan

# 1. Remove directories
if (Test-Path $InstallDir) {
    Write-Host "Removing installation directory: $InstallDir" -ForegroundColor DarkGray
    Remove-Item $InstallDir -Recurse -Force
} else {
    Write-Host "Installation directory not found. Skipping." -ForegroundColor Yellow
}

# 2. Update PATH
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$PathParts = $CurrentPath -split ";"
$NewPathParts = $PathParts | Where-Object { $_ -notlike "*$BinDir*" -and $_ -ne "" }

if ($PathParts.Count -ne $NewPathParts.Count) {
    $NewPath = $NewPathParts -join ";"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Host "Removed Frostty from User PATH." -ForegroundColor Green
    Write-Host "Restart PowerShell for changes to take effect." -ForegroundColor Yellow
} else {
    Write-Host "Frostty not found in User PATH." -ForegroundColor DarkGray
}

Write-Host "`nFrostty uninstallation complete!" -ForegroundColor Cyan
