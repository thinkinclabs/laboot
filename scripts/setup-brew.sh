#!/usr/bin/env bash
# setup-brew.sh (linux) — ensures Homebrew is installed. Idempotent.

set -euo pipefail

declare -f info >/dev/null 2>&1 || source <(curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/linux/scripts/utils.sh")

if command -v brew >/dev/null 2>&1; then
  info "brew already installed"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
