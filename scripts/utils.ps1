# utils.ps1 (windows) - shared helpers for laboot and its commands. Sourced
# remotely (never a local file, same as every other laboot script), so
# every command gets these for free without duplicating them.

function Info($msg) { Write-Host "[laboot] $msg" -ForegroundColor Cyan }
