# install.ps1 (windows) - installs or updates the laboot CLI itself. Idempotent.
# This is what a brand-new machine curls first; afterwards, `laboot install`
# re-runs this same script (fetched the same way as any other command) to
# update laboot in place - self-hosted, no separate maintenance path.
#
# Windows has no PATH-executable convention for a bare "laboot" the way
# unix does for a chmod +x script, so this installs laboot.ps1 to a fixed
# location and registers a `laboot` function in the user's PowerShell
# profile instead - works the same from any new PowerShell session.

$ErrorActionPreference = "Stop"

function Info($msg) { Write-Host "[laboot] $msg" -ForegroundColor Cyan }

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"
$InstallDir = "$env:LOCALAPPDATA\laboot"
$Bin = "$InstallDir\laboot.ps1"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/laboot.ps1" -OutFile $Bin
Info "Installed laboot to $Bin"

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$marker = "# >>> laboot >>>"
$markerEnd = "# <<< laboot <<<"
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

if ($profileContent -notmatch [regex]::Escape($marker)) {
    Add-Content -Path $PROFILE -Value "`n$marker`nfunction laboot { & `"$Bin`" @args }`n$markerEnd`n"
    Info "Added a 'laboot' function to your PowerShell profile: $PROFILE"
} else {
    Info "'laboot' function already present in your PowerShell profile"
}

Info "Open a new PowerShell session, then try: laboot setup_labrain"
