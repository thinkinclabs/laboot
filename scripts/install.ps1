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
#
# `laboot install` means $Ps1 is the file the currently-running process was
# launched from. Never write straight to it - download to a temp file and
# Move-Item into place (an atomic rename on the same volume), instead of an
# in-place overwrite, which can corrupt/duplicate the read mid-execution.

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

if (-not (Get-Command Info -ErrorAction SilentlyContinue)) {
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.ps1")
}

$InstallDir = "$env:LOCALAPPDATA\laboot"
$Ps1 = "$InstallDir\laboot.ps1"
$Cmd = "$InstallDir\laboot.cmd"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$Ps1Tmp = [System.IO.Path]::GetTempFileName()
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/laboot.ps1" -OutFile $Ps1Tmp

$changed = $true
if ((Test-Path $Ps1) -and (Test-Path $Cmd) -and ((Get-FileHash $Ps1Tmp).Hash -eq (Get-FileHash $Ps1).Hash)) {
    $changed = $false
}

if ($changed) {
    Move-Item -Path $Ps1Tmp -Destination $Ps1 -Force
    Set-Content -Path $Cmd -Value "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0laboot.ps1`" %*"
    Info "Installed laboot to $InstallDir"
} else {
    Remove-Item -Path $Ps1Tmp -Force
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $InstallDir) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$InstallDir", 'User')
    Info "Added $InstallDir to your User PATH"
} else {
    Info "$InstallDir already on your User PATH"
}

Info "Open a new terminal, then try: laboot setup-labrain"
