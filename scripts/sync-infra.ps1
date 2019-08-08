param(
    [string]$GitOpsRepoFolder = "../git-deploy"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$gitRootFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
while ((-not (Test-Path (Join-Path $gitRootFolder ".git"))) -and (-not $gitRootFolder.ToUpper().EndsWith("HDL"))) {
    $gitRootFolder = Split-Path $gitRootFolder -Parent
}
$GitOpsRepoFolder = Join-Path $gitRootFolder $GitOpsRepoFolder
$infraFolder = Join-Path $gitRootFolder "infra"

Write-Host "sync infra/generated"
$destinationComponentFolder = Join-Path (Join-Path $GitOpsRepoFolder "infra") "generated"
if (Test-Path $destinationComponentFolder) {
    Remove-Item $destinationComponentFolder -Recurse -Force
}
if (Test-Path (Join-Path $infraFolder "generated")) {
    Copy-Item -Path (Join-Path $infraFolder "generated") -Destination (Join-Path $GitOpsRepoFolder "infra") -Force -Recurse
}

Write-Host "sync infra/config"
$destinationComponentFolder = Join-Path (Join-Path $GitOpsRepoFolder "infra") "config"
if (Test-Path $destinationComponentFolder) {
    Remove-Item $destinationComponentFolder -Recurse -Force
}
if (Test-Path (Join-Path $infraFolder "config")) {
    Copy-Item -Path (Join-Path $infraFolder "config") -Destination (Join-Path $GitOpsRepoFolder "infra") -Force -Recurse
}

Set-Location $GitOpsRepoFolder
git add .
git commit -m "audo sync"
git pull
git push

Set-Location $gitRootFolder
