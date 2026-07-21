# xdayoungx repo publish script
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub login required. Browser will open."
    gh auth login -h github.com -p https -w
}

$repoUrl = "https://github.com/mickievely/xdayoungx.git"
gh repo view mickievely/xdayoungx --json url 2>$null
if ($LASTEXITCODE -ne 0) {
    gh repo create mickievely/xdayoungx --public --source=. --remote=origin --description "xdayoungx Bedwars Vape"
} else {
    git remote remove origin 2>$null
    git remote add origin $repoUrl
}

git push -u origin main
Write-Host ""
Write-Host "Done!"
Write-Host "Repo:  https://github.com/mickievely/xdayoungx"
Write-Host "Load:  https://raw.githubusercontent.com/mickievely/xdayoungx/main/load.lua"
Write-Host "Entry: https://raw.githubusercontent.com/mickievely/xdayoungx/main/xdayoungx.lua"
