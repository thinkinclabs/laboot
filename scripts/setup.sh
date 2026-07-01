#!/usr/bin/env bash
# setup.sh (linux) — orchestrator: runs setup-labrain then setup-obsidian.
# Both are already idempotent, so this is too.

set -euo pipefail

BRANCH="linux"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

laboot setup-labrain
laboot setup-obsidian
