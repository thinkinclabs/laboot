#!/usr/bin/env bash
# setup-sdkman.sh (mac) — ensures SDKMAN is installed. Idempotent.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if [ -d "$HOME/.sdkman" ]; then
  info "sdkman already installed"
else
  info "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi
