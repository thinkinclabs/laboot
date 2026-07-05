#!/usr/bin/env bash
# setup-nvm.sh (linux) — ensures nvm is installed. Idempotent.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/linux/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if [ -d "$HOME/.nvm" ]; then
  info "nvm already installed"
else
  info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
