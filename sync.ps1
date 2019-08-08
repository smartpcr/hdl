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
$svcFolder = Join-Path $gitRootFolder "svc"

fab install $infraFolder
$destinationComponentFolder = Join-Path $GitOpsRepoFolder "infra" "components"
if (Test-Path $destinationComponentFolder) {
    Remove-Item $destinationComponentFolder -Recurse -Force
}
Move-Item -Path (Join-Path $infraFolder "components") -Destination (Join-Path $GitOpsRepoFolder "infra") -Force
$childGitFolders = Get-ChildItem -Path $destinationComponentFolder -Recurse | Where-Object { $_.Name -eq ".git" }
if ($childGitFolders) {
    $childGitFolders | ForEach-Object {
        Remove-Item $_ -Recurse -Force
    }
}

fab install $svcFolder
$destinationComponentFolder = Join-Path $GitOpsRepoFolder "svc" "components"
if (Test-Path $destinationComponentFolder) {
    Remove-Item $destinationComponentFolder -Recurse -Force
}
Move-Item -Path $svcFolder -Destination (Join-Path $GitOpsRepoFolder "svc")

Set-Location $GitOpsRepoFolder
git add .
git commit -m "audo sync"
git pull
git push

Set-Location $gitRootFolder
