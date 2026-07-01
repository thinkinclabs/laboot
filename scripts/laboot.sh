#!/usr/bin/env bash
# laboot (linux) — fetch a URL, or resolve a named command on this branch,
# and forward it into bash. This is the installed CLI itself; keep it thin —
# real logic belongs in the individual command scripts, not here.
#
#   laboot <url>    fetch the URL, run it via bash
#   laboot <name>   fetch scripts/<name>.sh from this branch, run it via bash
#
# Sources utils.sh (shared helpers, e.g. the `info` banner) and exports its
# functions (bash-only feature) so every command run through laboot gets
# them for free — no script needs its own copy. Sourced via a temp file, not
# `source <(...)`: some bash builds' process substitution does not reliably
# persist functions defined via `source` into the calling shell (notably
# macOS's stock bash 3.2 — kept consistent here too).

set -euo pipefail

BRANCH="linux"
REPO="thinkinclabs/laboot"

_u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"
export -f info

target="${1:?Usage: laboot <url|command-name>}"

if [[ "$target" == http://* || "$target" == https://* ]]; then
  url="$target"
else
  url="https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/$target.sh"
fi

curl -fsSL "$url" | bash
