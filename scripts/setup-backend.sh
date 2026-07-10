#!/usr/bin/env bash
# setup-backend.sh (mac) — backend dev prerequisites: SDKMAN (Java/Gradle
# toolchain manager), via setup-sdkman. Idempotent. Afterwards, inside a
# repo with an .sdkmanrc, run `sdk env install` to get its pinned toolchain.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

laboot setup-sdkman

info "Backend prerequisites ready. In a repo with an .sdkmanrc: 'sdk env install'."
