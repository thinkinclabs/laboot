#!/usr/bin/env bash
# setup_gh.sh (linux) — ensures the GitHub CLI is installed and authenticated.
# Idempotent: already-installed / already-authenticated just skips ahead.

set -euo pipefail

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }

if command -v gh >/dev/null 2>&1; then
  info "gh already installed"
elif command -v apt-get >/dev/null 2>&1; then
  info "Installing GitHub CLI via apt..."
  (type -p wget >/dev/null || sudo apt-get install -y wget) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y gh
elif command -v dnf >/dev/null 2>&1; then
  info "Installing GitHub CLI via dnf..."
  sudo dnf install -y 'dnf-command(config-manager)'
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh --repo gh-cli
elif command -v pacman >/dev/null 2>&1; then
  info "Installing GitHub CLI via pacman..."
  sudo pacman -Sy --noconfirm github-cli
elif command -v brew >/dev/null 2>&1; then
  info "Installing GitHub CLI via Homebrew..."
  brew install gh
else
  info "No supported package manager found. Install gh manually: https://cli.github.com"
  exit 1
fi

if gh auth status >/dev/null 2>&1; then
  info "gh already authenticated"
else
  info "Log in to GitHub..."
  gh auth login
fi
