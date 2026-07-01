# setup-labrain.ps1 (windows) - bootstraps labrain (private repo) via gh. Idempotent.
# Depends on the setup-gh command, run through laboot itself - every
# prerequisite a command needs goes through `laboot <name>`, never a
# hand-rolled fetch, so there is one dependency mechanism, not two.
#
# labrain's own scripts/setup-labrain.sh is bash-only; it runs through Git for
# Windows' bundled bash.exe, which any git-based dev workflow already has.

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

if (-not (Get-Command Info -ErrorAction SilentlyContinue)) {
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.ps1")
}

if (-not (Get-Command laboot -ErrorAction SilentlyContinue)) {
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.ps1")
    $env:Path = "$env:LOCALAPPDATA\laboot;$env:Path"
}

Info "Ensuring GitHub CLI is ready..."
laboot setup-gh

$bash = "$env:ProgramFiles\Git\bin\bash.exe"
if (-not (Test-Path $bash)) {
    Info "Git for Windows not found at '$bash'. Install it: https://gitforwindows.org"
    exit 1
}

Info "Bootstrapping labrain..."
gh api repos/thinkinclabs/labrain/contents/scripts/setup-labrain.sh -H "Accept: application/vnd.github.raw" | & $bash -
