#!/usr/bin/env bash
# setup-sdkman.sh (windows) — ensures SDKMAN is installed. Idempotent. Runs
# under Git Bash — invoked by setup-sdkman.ps1, never directly on native
# PowerShell.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/windows/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if [ -d "$HOME/.sdkman" ]; then
  info "sdkman already installed"
else
  info "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi
