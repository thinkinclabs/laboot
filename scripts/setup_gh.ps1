# setup_gh.ps1 (windows) - ensures the GitHub CLI is installed and authenticated.
# Idempotent: already-installed / already-authenticated just skips ahead.

$ErrorActionPreference = "Stop"

function Info($msg) { Write-Host "[laboot] $msg" -ForegroundColor Cyan }

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Info "gh already installed"
} else {
    Info "Installing GitHub CLI via winget..."
    winget install --id GitHub.cli -e --source winget
}

gh auth status *> $null
if ($LASTEXITCODE -eq 0) {
    Info "gh already authenticated"
} else {
    Info "Log in to GitHub..."
    gh auth login
}
