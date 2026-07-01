#!/usr/bin/env bash
# setup-labrain.sh (linux) — bootstraps labrain (private repo) via gh. Idempotent.
# Depends on the setup-gh command, run through laboot itself — every
# prerequisite a command needs goes through `laboot <name>`, never a
# hand-rolled fetch, so there is one dependency mechanism, not two.

set -euo pipefail

BRANCH="linux"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || source <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh")

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

info "Ensuring GitHub CLI is ready..."
laboot setup-gh

info "Bootstrapping labrain..."
gh api repos/thinkinclabs/labrain/contents/scripts/setup-labrain.sh -H "Accept: application/vnd.github.raw" | bash
