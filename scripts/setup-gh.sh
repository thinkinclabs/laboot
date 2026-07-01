#!/usr/bin/env bash
# setup-gh.sh (mac) — ensures the GitHub CLI is installed and authenticated.
# Idempotent: already-installed / already-authenticated just skips ahead.
# Depends on the setup-brew command, run through laboot itself — every
# prerequisite a command needs goes through `laboot <name>`, never a
# hand-rolled fetch, so there is one dependency mechanism, not two.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

if command -v gh >/dev/null 2>&1; then
  info "gh already installed"
else
  info "Installing GitHub CLI via Homebrew..."
  laboot setup-brew
  brew install gh
fi

if gh auth status >/dev/null 2>&1; then
  info "gh already authenticated"
else
  info "Log in to GitHub..."
  gh auth login
fi
