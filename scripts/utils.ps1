# utils.ps1 (windows) - shared helpers for laboot and its commands. Sourced
# remotely (never a local file, same as every other laboot script), so
# every command gets these for free without duplicating them.

function Info($msg) { Write-Host "[laboot] $msg" -ForegroundColor Cyan }

# Some commands (e.g. setup-nvm, setup-sdkman) have no native Windows
# installer and delegate to the same bash script mac/linux use, run through
# Git for Windows' bundled bash.exe.
function Get-GitBash {
    $bash = "$env:ProgramFiles\Git\bin\bash.exe"
    if (-not (Test-Path $bash)) {
        Info "Git for Windows not found at '$bash'. Install it: https://gitforwindows.org"
        exit 1
    }
    return $bash
}
