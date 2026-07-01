#!/usr/bin/env bash
# setup-nvm.sh (linux) — ensures nvm is installed. Idempotent.

set -euo pipefail

declare -f info >/dev/null 2>&1 || source <(curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/linux/scripts/utils.sh")

if [ -d "$HOME/.nvm" ]; then
  info "nvm already installed"
else
  info "Installing nvm..."
  git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
fi
