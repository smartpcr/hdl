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

Set-Location $infraFolder
fab add cloud-native `
    --source https://github.com/microsoft/fabrikate-definitions `
    --path definitions/fabrikate-cloud-native


Set-Location $gitRootFolder