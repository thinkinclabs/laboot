#!/usr/bin/env bash
# setup-brew.sh (mac) — ensures Homebrew is installed. Idempotent.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if command -v brew >/dev/null 2>&1; then
  info "brew already installed"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
