#!/usr/bin/env bash
# laboot (mac) — fetch a URL, or resolve a named command on this branch, and
# forward it into bash. This is the installed CLI itself; keep it thin — real
# logic belongs in the individual command scripts, not here.
#
#   laboot <url>    fetch the URL, run it via bash
#   laboot <name>   fetch scripts/<name>.sh from this branch, run it via bash

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"

target="${1:?Usage: laboot <url|command-name>}"

if [[ "$target" == http://* || "$target" == https://* ]]; then
  url="$target"
else
  url="https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/$target.sh"
fi

curl -fsSL "$url" | bash
