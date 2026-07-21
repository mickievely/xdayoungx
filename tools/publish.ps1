# xdayoungx repo publish script
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub login required. Browser will open."
    gh auth login -h github.com -p https -w
}

$repo = gh repo view xdayoungx/gokuvape --json url 2>$null
if ($LASTEXITCODE -ne 0) {
    gh repo create xdayoungx/gokuvape --public --source=. --remote=origin --description "xdayoungx Bedwars Vape (modular)"
} else {
    git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0) {
        git remote add origin https://github.com/xdayoungx/gokuvape.git
    }
}

git push -u origin main
Write-Host ""
Write-Host "Done!"
Write-Host "Repo:  https://github.com/xdayoungx/gokuvape"
Write-Host "Raw:   https://raw.githubusercontent.com/xdayoungx/gokuvape/main/gokuvape.lua"
