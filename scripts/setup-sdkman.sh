#!/usr/bin/env bash
# setup-sdkman.sh (mac) — ensures SDKMAN is installed. Idempotent.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if [ -d "$HOME/.sdkman" ]; then
  info "sdkman already installed"
else
  info "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
fi
