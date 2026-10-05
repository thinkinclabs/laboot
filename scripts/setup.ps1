# setup.ps1 (windows) - orchestrator: runs setup-labrain,
# setup-labrain-hook, then setup-obsidian. All are already idempotent, so
# this is too.

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

laboot setup-labrain
laboot setup-labrain-hook
laboot setup-obsidian
