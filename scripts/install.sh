#!/usr/bin/env bash
# install.sh (main) — the platform-agnostic entrypoint. Resolves which
# platform branch applies, installs laboot from it if missing, and forwards
# any arguments on to the CLI.
#
# Every caller used to carry this branch-selection block itself:
#
#   LABOOT_BRANCH="linux"
#   [[ "$(uname)" == "Darwin" ]] && LABOOT_BRANCH="mac"
#   if ! command -v laboot >/dev/null 2>&1; then
#     bash <(curl -fsSL ".../$LABOOT_BRANCH/scripts/install.sh")
#     export PATH="$HOME/.local/bin:$PATH"
#   fi
#   laboot setup-sdkman
#
# which meant every consumer repo hardcoded the branch names and had to be
# edited whenever the platform layout changed. That block now lives here and
# collapses to one line at the call site:
#
#   curl -fsSL ".../main/scripts/install.sh" | bash -s -- setup-sdkman
#
# main stays free of platform-specific logic: this script only picks a
# branch and delegates. The real installer remains one copy per platform, on
# that platform's branch, so `laboot install` keeps self-updating from the
# same file it was installed from.

set -euo pipefail

REPO="thinkinclabs/laboot"
INSTALL_DIR="$HOME/.local/bin"
RAW="https://raw.githubusercontent.com/$REPO"

case "$(uname -s)" in
  Darwin)
    BRANCH="mac"
    ;;
  Linux)
    BRANCH="linux"
    ;;
  MINGW* | MSYS* | CYGWIN*)
    echo "laboot: Windows is installed through PowerShell, not bash. Run:" >&2
    echo "  irm $RAW/windows/scripts/install.ps1 | iex" >&2
    exit 1
    ;;
  *)
    echo "laboot: unsupported platform '$(uname -s)'." >&2
    echo "Supported: Darwin (mac), Linux (linux), Windows (windows, PowerShell)." >&2
    exit 1
    ;;
esac

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "$RAW/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

# Put the install dir on PATH before probing for laboot, so an existing
# install that simply is not on this shell's PATH counts as present rather
# than triggering a needless reinstall.
case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    ;;
  *)
    export PATH="$INSTALL_DIR:$PATH"
    ;;
esac

# Reinstalling on every call would charge each CI job two extra fetches for a
# CLI that is already correct, so the default is to skip when one is present.
#
# "Present" is not enough on its own, though: the CLI pins the branch it
# resolves commands from, so a laboot installed from the wrong branch silently
# runs another platform's scripts forever — a Linux box holding the mac build
# fetches mac's setup-sdkman, which reaches for Homebrew and
# /opt/homebrew/bin/bash. Nothing ever corrects that, because the old guard
# only asked whether laboot existed. Compare the pin and reinstall on a
# mismatch.
#
# This does couple the router to laboot.sh's own `BRANCH="..."` line. If that
# line is ever reshaped the grep stops matching and every call reinstalls,
# which is wasteful but not wrong — the per-branch installer is idempotent and
# writes nothing when the content is unchanged.
needs_install=0
if ! command -v laboot >/dev/null 2>&1; then
  needs_install=1
elif ! grep -q "^BRANCH=\"$BRANCH\"" "$(command -v laboot)" 2>/dev/null; then
  info "Installed laboot targets a different platform; reinstalling from $BRANCH"
  needs_install=1
elif [ "${LABOOT_FORCE_INSTALL:-0}" = "1" ]; then
  needs_install=1
fi

if [ "$needs_install" = "1" ]; then
  info "Resolved platform branch: $BRANCH"
  curl -fsSL "$RAW/$BRANCH/scripts/install.sh" | bash
fi

# Argument forwarding is what lets a caller install-and-run in one line. With
# no arguments this behaves exactly like the per-branch installer: install,
# then stop. `exec` so the command's exit status is this script's.
if [ "$#" -gt 0 ]; then
  exec laboot "$@"
fi
