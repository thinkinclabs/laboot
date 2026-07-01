#!/usr/bin/env bash
# setup-labrain.sh (mac) — bootstraps labrain (private repo) via gh. Idempotent.
# Depends on the setup-gh command, run through laboot itself — every
# prerequisite a command needs goes through `laboot <name>`, never a
# hand-rolled fetch, so there is one dependency mechanism, not two.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

info "Ensuring GitHub CLI is ready..."
laboot setup-gh

info "Bootstrapping labrain..."
gh api repos/thinkinclabs/labrain/contents/scripts/setup-labrain.sh -H "Accept: application/vnd.github.raw" | bash
