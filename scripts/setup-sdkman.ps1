# setup-sdkman.ps1 (windows) - ensures SDKMAN is installed. Idempotent.
# SDKMAN has no native Windows installer; this runs the same bash-based
# install as mac/linux through Git for Windows' bundled bash.exe.

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

if (-not (Get-Command Info -ErrorAction SilentlyContinue)) {
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.ps1")
}

$bash = Get-GitBash

Info "Installing SDKMAN via Git Bash..."
& $bash -c "curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/setup-sdkman.sh | bash"
