#!/usr/bin/env bash
# setup-web.sh (mac) — web dev prerequisites: nvm (via setup-nvm), Node
# (from .nvmrc when the current directory has one, else latest LTS) and
# Yarn via corepack. Idempotent. Ends by offering the native suite
# (setup-native: Android emulator/adb + iOS). The answer is read from
# /dev/tty, not stdin — this script normally runs as `curl | bash`, where
# stdin is the script itself. Non-interactive runs (CI) skip the offer;
# set LABOOT_NATIVE=1 to force it, LABOOT_NATIVE=0 to silence it.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

laboot setup-nvm

(
  set +u
  # shellcheck source=/dev/null
  . "$HOME/.nvm/nvm.sh"
  if [ -f .nvmrc ]; then
    info "Installing Node from ./.nvmrc..."
    nvm install
  else
    info "Installing latest LTS Node..."
    nvm install --lts
  fi
  info "Enabling corepack (Yarn)..."
  corepack enable
)

want="${LABOOT_NATIVE:-}"
if [ -z "$want" ] && { : < /dev/tty; } 2>/dev/null; then
  read -r -p "[laboot] Set up the native suite too (Android emulator + adb, iOS)? [y/N] " want < /dev/tty || want=""
fi
case "$want" in
  1|y|Y|yes|YES)
    laboot setup-native
    ;;
  *)
    info "Skipping native suite. Run 'laboot setup-native' anytime."
    ;;
esac

info "Web prerequisites ready."
