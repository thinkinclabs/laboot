#!/usr/bin/env bash
# utils.sh (windows) — shared bash helpers for the windows-branch commands
# that delegate to Git Bash (setup-nvm, setup-sdkman). Sourced remotely
# (never a local file, same as every other laboot script). Sourced via a
# temp file, not `source <(...)`: some bash builds' process substitution
# does not reliably persist functions defined via `source` into the
# calling shell.

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }
