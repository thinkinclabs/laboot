# setup-labrain-hook.ps1 (windows) - installs the Claude Code SessionStart
# hook that keeps the local labrain clone current, into the user-level
# settings (~\.claude\settings.json). Idempotent. Run after setup-labrain.
#
# The merge into settings.json lives in this branch's own
# setup-labrain-hook.sh (bash + jq), run through Git for Windows' bundled
# bash.exe - the same shell Claude Code runs the hook itself through.

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

if (-not (Get-Command Info -ErrorAction SilentlyContinue)) {
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.ps1")
}

# setup-labrain sets LABRAIN_PATH as a User environment variable, which a
# session that was already open (e.g. `laboot setup` chaining both) does not
# see yet - read it from there.
if (-not $env:LABRAIN_PATH) {
    $env:LABRAIN_PATH = [Environment]::GetEnvironmentVariable("LABRAIN_PATH", "User")
}

if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
    Info "Installing jq via winget..."
    winget install --id jqlang.jq -e --source winget
    # winget exposes new commands through its Links folder, which this
    # session's PATH predates.
    $env:Path = "$env:LOCALAPPDATA\Microsoft\WinGet\Links;$env:Path"
}

$bash = Get-GitBash

Info "Installing the labrain SessionStart hook..."
& $bash -c "curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/setup-labrain-hook.sh | bash"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
