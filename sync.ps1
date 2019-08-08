
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$gitRootFolder = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
while ((-not (Test-Path (Join-Path $gitRootFolder ".git"))) -and (-not $gitRootFolder.ToUpper().EndsWith("HDL"))) {
    $gitRootFolder = Split-Path $gitRootFolder -Parent
}

fab install ./infra
Move-Item -Path ./infra/components -Destination ./manifest/infra -Force
Set-Location (Join-Path $gitRootFolder "manifest" "infra")
git add .
git commit -m "audo sync"
git push 