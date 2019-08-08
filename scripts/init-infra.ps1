
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$gitRootFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
while ((-not (Test-Path (Join-Path $gitRootFolder ".git"))) -and (-not $gitRootFolder.ToUpper().EndsWith("HDL"))) {
    $gitRootFolder = Split-Path $gitRootFolder -Parent
}

$infraFolder = Join-Path $gitRootFolder "infra"

Set-Location $infraFolder
fab add cloud-native `
    --source https://github.com/smartpcr/fabrikate-definitions `
    --path definitions/fabrikate-cloud-native

fab install
# add modification here
fab generate dev

Set-Location $gitRootFolder