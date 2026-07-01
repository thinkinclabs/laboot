# laboot.ps1 (windows) - fetch a URL, or resolve a named command on this
# branch, and forward it into PowerShell. This is the installed CLI itself;
# keep it thin - real logic belongs in the individual command scripts.
#
#   laboot <url>    fetch the URL, run it via PowerShell
#   laboot <name>   fetch scripts/<name>.ps1 from this branch, run it
#
# Sources utils.ps1 (shared helpers, e.g. the Info banner) via
# Invoke-Expression, which runs in the calling scope - so it and every
# command run through laboot after it share the same defined functions,
# no script needs its own copy.

param(
    [Parameter(Mandatory = $true)]
    [string]$Target
)

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.ps1")

if ($Target -match '^https?://') {
    $url = $Target
} else {
    $url = "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/$Target.ps1"
}

Invoke-Expression (Invoke-RestMethod -Uri $url)
