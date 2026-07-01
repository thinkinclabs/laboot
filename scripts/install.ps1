# install.ps1 (windows) - installs or updates the laboot CLI itself. Idempotent.
# This is what a brand-new machine curls first; afterwards, `laboot install`
# re-runs this same script (fetched the same way as any other command) to
# update laboot in place - self-hosted, no separate maintenance path.
#
# Installs laboot.ps1 plus a laboot.cmd shim (PATHEXT-resolved, works from
# cmd.exe and PowerShell alike) into a fixed dir, then adds that dir to the
# User PATH if it isn't already there. Deliberately not $PROFILE-based:
# $PROFILE resolves to a different path per PowerShell host, so a function
# registered there is invisible from other hosts (or even other pwsh
# invocations in non-interactive contexts) - a PATH shim is host-agnostic.

$ErrorActionPreference = "Stop"

function Info($msg) { Write-Host "[laboot] $msg" -ForegroundColor Cyan }

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"
$InstallDir = "$env:LOCALAPPDATA\laboot"
$Ps1 = "$InstallDir\laboot.ps1"
$Cmd = "$InstallDir\laboot.cmd"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/laboot.ps1" -OutFile $Ps1
Set-Content -Path $Cmd -Value "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0laboot.ps1`" %*"
Info "Installed laboot to $InstallDir"

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $InstallDir) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$InstallDir", 'User')
    Info "Added $InstallDir to your User PATH"
} else {
    Info "$InstallDir already on your User PATH"
}

Info "Open a new terminal, then try: laboot setup_labrain"
