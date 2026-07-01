#!/usr/bin/env bash
# setup_gh.sh (mac) — ensures the GitHub CLI is installed and authenticated.
# Idempotent: already-installed / already-authenticated just skips ahead.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if command -v gh >/dev/null 2>&1; then
  info "gh already installed"
else
  info "Installing GitHub CLI via Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    info "Homebrew not found — installing it first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install gh
fi

if gh auth status >/dev/null 2>&1; then
  info "gh already authenticated"
else
  info "Log in to GitHub..."
  gh auth login
fi
