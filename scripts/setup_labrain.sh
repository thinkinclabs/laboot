#!/usr/bin/env bash
# setup_labrain.sh (linux) — bootstraps labrain (private repo) via gh. Idempotent.
# Depends on setup_gh.sh, fetched from this same branch (never a local file —
# this script itself is always run as a single remote curl target).

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

info "Ensuring GitHub CLI is ready..."
bash <(curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/linux/scripts/setup_gh.sh")

info "Bootstrapping labrain..."
gh api repos/thinkinclabs/labrain/contents/scripts/setup-labrain.sh -H "Accept: application/vnd.github.raw" | bash
