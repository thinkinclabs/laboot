#!/usr/bin/env bash
# setup-nvm.sh (windows) — ensures nvm is installed. Idempotent. Runs under
# Git Bash — invoked by setup-nvm.ps1, never directly on native PowerShell.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/windows/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if [ -d "$HOME/.nvm" ]; then
  info "nvm already installed"
else
  info "Installing nvm..."
  git clone --depth=1 https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
fi
