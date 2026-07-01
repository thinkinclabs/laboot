#!/usr/bin/env bash
# setup-nvm.sh (linux) — ensures nvm is installed. Idempotent.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/linux/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if [ -d "$HOME/.nvm" ]; then
  info "nvm already installed"
else
  info "Installing nvm..."
  git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
fi
