# setup_labrain.ps1 (windows) - bootstraps labrain (private repo) via gh. Idempotent.
# Depends on setup_gh.ps1, fetched from this same branch (never a local file -
# this script itself is always run as a single remote irm target).
#
# labrain's own scripts/setup-labrain.sh is bash-only; it runs through Git for
# Windows' bundled bash.exe, which any git-based dev workflow already has.

$ErrorActionPreference = "Stop"

function Info($msg) { Write-Host "[laboot] $msg" -ForegroundColor Cyan }

Info "Ensuring GitHub CLI is ready..."
Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/thinkinclabs/laboot/windows/scripts/setup_gh.ps1")

$bash = "$env:ProgramFiles\Git\bin\bash.exe"
if (-not (Test-Path $bash)) {
    Info "Git for Windows not found at '$bash'. Install it: https://gitforwindows.org"
    exit 1
}

Info "Bootstrapping labrain..."
gh api repos/thinkinclabs/labrain/contents/scripts/setup-labrain.sh -H "Accept: application/vnd.github.raw" | & $bash -
