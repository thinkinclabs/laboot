# laboot.ps1 (windows) - fetch a URL, or resolve a named command on this
# branch, and forward it into PowerShell. This is the installed CLI itself;
# keep it thin - real logic belongs in the individual command scripts.
#
#   laboot <url>    fetch the URL, run it via PowerShell
#   laboot <name>   fetch scripts/<name>.ps1 from this branch, run it

param(
    [Parameter(Mandatory = $true)]
    [string]$Target
)

$ErrorActionPreference = "Stop"

$BRANCH = "windows"
$REPO = "thinkinclabs/laboot"

if ($Target -match '^https?://') {
    $url = $Target
} else {
    $url = "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/$Target.ps1"
}

Invoke-Expression (Invoke-RestMethod -Uri $url)
