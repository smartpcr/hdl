param(
    [array]$GitOpsRepoFolders = @("../git-deploy", "../../../my/git-deploy", "../../../sace"),
    [string]$Comments = "sync infra"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$gitRootFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
while ((-not (Test-Path (Join-Path $gitRootFolder ".git"))) -and (-not $gitRootFolder.ToUpper().EndsWith("HDL"))) {
    $gitRootFolder = Split-Path $gitRootFolder -Parent
}

$GitOpsRepoFolders | ForEach-Object {
    $GitOpsRepoFolder = $_
    $GitOpsRepoFolder = Join-Path $gitRootFolder $GitOpsRepoFolder
    $infraFolder = Join-Path $gitRootFolder "infra"

    Write-Host "sync infra/generated"
    $destinationInfraFolder = Join-Path (Join-Path $GitOpsRepoFolder "generated") "infra"
    if (Test-Path $destinationInfraFolder) {
        Remove-Item $destinationInfraFolder -Recurse -Force
    }

    $sourceInfraFolder = Join-Path $infraFolder "generated"
    if (Test-Path $sourceInfraFolder) {
       Get-ChildItem $sourceInfraFolder -Recurse | Copy-Item -Destination $destinationInfraFolder -Force
    }

    Write-Host "sync infra/config"
    $destinationConfigFolder = Join-Path (Join-Path $GitOpsRepoFolder "config") "infra"
    if (Test-Path $destinationConfigFolder) {
        Remove-Item $destinationConfigFolder -Recurse -Force
    }
    $sourceConfigFolder = Join-Path $infraFolder "config"
    if (Test-Path $sourceConfigFolder) {
        Get-ChildItem $sourceConfigFolder -Recurse | Copy-Item -Destination $destinationConfigFolder -Force
    }

    Set-Location $GitOpsRepoFolder

    git add .
    git commit -m $Comments
    git pull
    git push

    Set-Location $gitRootFolder
}
