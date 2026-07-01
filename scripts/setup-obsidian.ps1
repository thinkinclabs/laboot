# setup-obsidian.ps1 (windows) - installs/refreshes kepano/obsidian-skills
# into labrain's ./.claude. Idempotent. No native Windows installer for
# this; runs the same bash script mac/linux use through Git for Windows'
# bundled bash.exe.

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

Info "Installing obsidian-skills..."
& $bash -c "curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/setup-obsidian.sh | bash"
