
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
    $GitOpsRepoFolder = $_

    $GitOpsRepoFolder = Join-Path $gitRootFolder $GitOpsRepoFolder
    $svcFolder = Join-Path $gitRootFolder "svc"

    Write-Host "sync svc/generated"
    $destinationComponentFolder = Join-Path (Join-Path $GitOpsRepoFolder "svc") "generated"
    if (Test-Path $destinationComponentFolder) {
        Remove-Item $destinationComponentFolder -Recurse -Force
    }
    if (Test-Path (Join-Path $svcFolder "generated")) {
        Copy-Item -Path (Join-Path $svcFolder "generated") -Destination (Join-Path $GitOpsRepoFolder "svc") -Force -Recurse
    }

    Write-Host "sync svc/config"
    $destinationComponentFolder = Join-Path (Join-Path $GitOpsRepoFolder "svc") "config"
    if (Test-Path $destinationComponentFolder) {
        Remove-Item $destinationComponentFolder -Recurse -Force
    }
    if (Test-Path (Join-Path $svcFolder "config")) {
        Copy-Item -Path (Join-Path $svcFolder "config") -Destination (Join-Path $GitOpsRepoFolder "svc") -Force -Recurse
    }

    Set-Location $GitOpsRepoFolder

    git add .
    git commit -m $Comments
    git pull
    git push

    Set-Location $gitRootFolder
}
