#!/usr/bin/env bash
# setup-sdkman.sh (mac) — ensures SDKMAN is installed. Idempotent.
# SDKMAN's own installer requires Bash 4+; macOS ships bash 3.2 as
# /bin/bash, so this ensures Homebrew (via laboot) and runs the installer
# through its modern bash instead.

set -euo pipefail

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if [ -d "$HOME/.sdkman" ]; then
  info "sdkman already installed"
else
  if ! command -v laboot >/dev/null 2>&1; then
    bash <(curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/install.sh")
    export PATH="$HOME/.local/bin:$PATH"
  fi
  laboot setup-brew

  modern_bash=""
  for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [ -x "$candidate" ]; then
      modern_bash="$candidate"
      break
    fi
  done
  if [ -z "$modern_bash" ]; then
    info "Installing a modern bash via Homebrew (SDKMAN requires Bash 4+)..."
    brew install bash
    for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
      if [ -x "$candidate" ]; then
        modern_bash="$candidate"
        break
      fi
    done
  fi

  info "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | "$modern_bash"
fi
