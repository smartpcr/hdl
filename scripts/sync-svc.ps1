
param(
    [array]$GitOpsRepoFolders = @("../git-deploy", "../../../my/git-deploy", "../../../sace"),
    [string]$Comments = "sync services"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$gitRootFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
while ((-not (Test-Path (Join-Path $gitRootFolder ".git"))) -and (-not $gitRootFolder.ToUpper().EndsWith("HDL"))) {
    $gitRootFolder = Split-Path $gitRootFolder -Parent
}

$GitOpsRepoFolders | ForEach-Object {
    $GitOpsRepoFolder = Join-Path $gitRootFolder $_

    $GitOpsRepoFolder = Join-Path $gitRootFolder $GitOpsRepoFolder
    $svcFolder = Join-Path $gitRootFolder "svc"

    Write-Host "sync svc/generated"
    New-Item (Join-Path $GitOpsRepoFolder "generated") -ItemType Directory -Force | Out-Null
    $desginationSvcFolder = Join-Path (Join-Path $GitOpsRepoFolder "generated") "svc"
    if (Test-Path $desginationSvcFolder) {
        Remove-Item $desginationSvcFolder -Recurse -Force
    }
    $sourceSvcFolder = Join-Path $svcFolder "generated"
    if (Test-Path $sourceSvcFolder) {
        Get-ChildItem $sourceSvcFolder -Recurse | Copy-Item -Destination $desginationSvcFolder -Force
    }

    Write-Host "sync config/svc"
    New-Item (Join-Path $GitOpsRepoFolder "config") -ItemType Directory -Force | Out-Null
    $desginationConfigFolder = Join-Path (Join-Path $GitOpsRepoFolder "config") "svc"
    if (Test-Path $desginationConfigFolder) {
        Remove-Item $desginationConfigFolder -Recurse -Force
    }
    $sourceConfigFolder = Join-Path $svcFolder "config"
    if (Test-Path $sourceConfigFolder) {
        Get-ChildItem $sourceConfigFolder -Recurse | Copy-Item -Destination $desginationConfigFolder -Force
    }

    Set-Location $GitOpsRepoFolder

    git add .
    git commit -m $Comments
    git pull
    git push

    Set-Location $gitRootFolder
}
