#!/usr/bin/env bash
# install.sh (mac) — installs or updates the laboot CLI itself. Idempotent.
# This is what a brand-new machine curls first; afterwards, `laboot install`
# re-runs this same script (fetched the same way as any other command) to
# update laboot in place — self-hosted, no separate maintenance path.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"
INSTALL_DIR="$HOME/.local/bin"
BIN="$INSTALL_DIR/laboot"

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

mkdir -p "$INSTALL_DIR"
curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/laboot.sh" -o "$BIN"
chmod +x "$BIN"
info "Installed laboot to $BIN"

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    ;;
  *)
    info "$INSTALL_DIR is not on your PATH. Add this to your shell rc:"
    printf '\n    export PATH="%s:$PATH"\n\n' "$INSTALL_DIR"
    ;;
esac

info "Try: laboot setup_labrain"
