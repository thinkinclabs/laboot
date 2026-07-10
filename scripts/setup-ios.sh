#!/usr/bin/env bash
# setup-ios.sh (mac) — iOS tooling for native dev: Xcode Command Line
# Tools, watchman and CocoaPods. Idempotent. Full Xcode (needed for the
# iOS simulator) can't be installed unattended — it requires an App Store
# login — so it's checked and instructed, not forced.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }
warn() { printf '\033[1;33m[laboot]\033[0m %s\n' "$1" >&2; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

laboot setup-brew

if xcode-select -p >/dev/null 2>&1; then
  info "Xcode Command Line Tools already installed"
else
  info "Requesting Xcode Command Line Tools install (GUI dialog will open)..."
  xcode-select --install || true
  warn "Finish the dialog, then re-run 'laboot setup-ios'."
fi

if command -v watchman >/dev/null 2>&1; then
  info "watchman already installed"
else
  info "Installing watchman..."
  brew install watchman
fi

if command -v pod >/dev/null 2>&1; then
  info "CocoaPods already installed"
else
  info "Installing CocoaPods..."
  brew install cocoapods
fi

if [ -d "/Applications/Xcode.app" ]; then
  info "Xcode found"
  info "If freshly installed: 'sudo xcodebuild -license accept', then open Xcode once to install the iOS platform (simulator runtime)."
else
  warn "Full Xcode not found — install it from the App Store (needed for the iOS simulator):"
  warn "  https://apps.apple.com/app/xcode/id497799835"
  warn "Then: 'sudo xcodebuild -license accept' and open Xcode once to install the iOS platform."
fi

info "iOS tooling ready."
