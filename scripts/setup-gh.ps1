# setup-gh.ps1 (windows) - ensures the GitHub CLI is installed and authenticated.
# Idempotent: already-installed / already-authenticated just skips ahead.

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

if (-not (Get-Command Info -ErrorAction SilentlyContinue)) {
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.ps1")
}

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
