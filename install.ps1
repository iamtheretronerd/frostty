param(
    [string]$Version = "",
    [switch]$NoModifyPath
)

$ErrorActionPreference = "Stop"

$Repo = "iamtheretronerd/frostty"
$InstallDir = "$env:USERPROFILE\.frostty\bin"
$ZipPath = "$env:TEMP\frostty.zip"
$ExtractPath = "$env:TEMP\frostty"

Write-Host "`nInstalling Frostty..." -ForegroundColor Cyan

# Create install directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Get release info
if ([string]::IsNullOrWhiteSpace($Version)) {
    Write-Host "Fetching latest version..." -ForegroundColor DarkGray
    $Release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
} else {
    Write-Host "Fetching version $Version..." -ForegroundColor DarkGray
    $Version = $Version.TrimStart("v")
    $Release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/tags/v$Version"
}

# Find Windows asset
$Asset = $Release.assets | Where-Object { $_.name -like "*windows-x64.zip" }

if (-not $Asset) {
    Write-Host "Windows build not found in release." -ForegroundColor Red
    exit 1
}

Write-Host "Downloading $($Asset.name)..." -ForegroundColor DarkGray
Invoke-WebRequest $Asset.browser_download_url -OutFile $ZipPath

# Extract
Remove-Item $ExtractPath -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $ZipPath -DestinationPath $ExtractPath -Force

# Move binary
$Exe = Get-ChildItem $ExtractPath -Recurse -Filter "frostty.exe" | Select-Object -First 1

if (-not $Exe) {
    Write-Host "frostty.exe not found in archive." -ForegroundColor Red
    exit 1
}

Copy-Item $Exe.FullName "$InstallDir\frostty.exe" -Force

Write-Host "Installed to $InstallDir" -ForegroundColor Green

# Add to PATH
if (-not $NoModifyPath) {
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($CurrentPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$InstallDir", "User")
        Write-Host "Added Frostty to PATH (User)." -ForegroundColor Green
        Write-Host "Restart PowerShell to use it." -ForegroundColor Yellow
    } else {
        Write-Host "Frostty already in PATH." -ForegroundColor DarkGray
    }
}

Write-Host "`nFrostty installation complete!" -ForegroundColor Cyan
Write-Host "Run: frostty --version`n"
