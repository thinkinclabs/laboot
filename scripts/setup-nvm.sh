#!/usr/bin/env bash
# setup-nvm.sh (mac) — ensures nvm is installed. Idempotent.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if [ -d "$HOME/.nvm" ]; then
  info "nvm already installed"
else
  info "Installing nvm..."
  git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
fi
