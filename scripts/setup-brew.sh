#!/usr/bin/env bash
# setup-brew.sh (mac) — ensures Homebrew is installed. Idempotent.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if command -v brew >/dev/null 2>&1; then
  info "brew already installed"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
