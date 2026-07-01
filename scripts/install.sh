#!/usr/bin/env bash
# install.sh (mac) — installs or updates the laboot CLI itself. Idempotent.
# This is what a brand-new machine curls first; afterwards, `laboot install`
# re-runs this same script (fetched the same way as any other command) to
# update laboot in place — self-hosted, no separate maintenance path.
#
# `laboot install` means $BIN is the file currently executing (the running
# `laboot` process IS ~/.local/bin/laboot). Never write straight to it —
# curl to a temp file and `mv` into place, since rename is atomic and
# doesn't touch the inode the running process already has open, unlike an
# in-place overwrite, which can corrupt/duplicate the read mid-execution.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"
INSTALL_DIR="$HOME/.local/bin"
BIN="$INSTALL_DIR/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

mkdir -p "$INSTALL_DIR"
_bin_tmp=$(mktemp)
curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/laboot.sh" -o "$_bin_tmp"
chmod +x "$_bin_tmp"
if [ -f "$BIN" ] && cmp -s "$_bin_tmp" "$BIN"; then
  rm -f "$_bin_tmp"
else
  mv "$_bin_tmp" "$BIN"
  info "Installed laboot to $BIN"
fi

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    ;;
  *)
    info "$INSTALL_DIR is not on your PATH. Add this to your shell rc:"
    printf '\n    export PATH="%s:$PATH"\n\n' "$INSTALL_DIR"
    ;;
esac

info "Try: laboot setup-labrain"
