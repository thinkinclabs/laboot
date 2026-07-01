# setup-labrain.ps1 (windows) - bootstraps labrain (private repo) via gh. Idempotent.
# Depends on the setup-gh command, run through laboot itself - every
# prerequisite a command needs goes through `laboot <name>`, never a
# hand-rolled fetch, so there is one dependency mechanism, not two.
#
# The clone+persist logic lives in this branch's own setup-labrain.sh (bash),
# run through Git for Windows' bundled bash.exe, which any git-based dev
# workflow already has. This used to fetch and run a copy of that logic
# from the labrain repo itself via the GitHub contents API; it's now a
# laboot command like everything else.

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

$bash = Get-GitBash

Info "Bootstrapping labrain..."
& $bash -c "curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/setup-labrain.sh | bash"
