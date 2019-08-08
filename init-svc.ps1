param(
    [string]$ServiceManifestFile = "~/work/github/aks-bootstrap/deploy/examples/1es/services.yaml"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$gitRootFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
while ((-not (Test-Path (Join-Path $gitRootFolder ".git"))) -and (-not $gitRootFolder.ToUpper().EndsWith("HDL"))) {
    $gitRootFolder = Split-Path $gitRootFolder -Parent
}
$GitOpsRepoFolder = Join-Path $gitRootFolder $GitOpsRepoFolder
$svcFolder = Join-Path $gitRootFolder "svc"

Set-Location $svcFolder
fab add cloud-native `
    --source https://github.com/microsoft/fabrikate-definitions `
    --path definitions/fabrikate-cloud-native


Set-Location $gitRootFolder