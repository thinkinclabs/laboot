#!/usr/bin/env bash
# setup-ios.sh (mac) — iOS tooling for native dev: Xcode Command Line
# Tools, watchman, CocoaPods and the iOS simulator runtime. Idempotent.
#
# Full Xcode (needed for the simulator) can't be installed unattended — it
# requires an App Store login — and selecting it, its first-launch tasks and
# its license all need sudo. Those are checked and instructed, not forced:
# each prints the one command to run, and the script ends by saying whether
# iOS tooling is ready or what is still pending.

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

pending=0
needs() { warn "$1"; pending=1; }

if xcode-select -p >/dev/null 2>&1; then
  info "Xcode Command Line Tools already installed"
else
  info "Requesting Xcode Command Line Tools install (GUI dialog will open)..."
  xcode-select --install || true
  warn "Finish the dialog, then re-run 'laboot setup-ios' — Homebrew needs the tools for the rest."
  exit 0
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

# Full Xcode is "there" only when xcodebuild works, which needs xcode-select
# pointing at it — with just the Command Line Tools selected, xcodebuild
# refuses to run even if Xcode.app is installed.
if xcodebuild -version >/dev/null 2>&1; then
  info "Xcode found ($(xcodebuild -version 2>/dev/null | head -n 1))"

  # Captured before matching: under `pipefail`, piping straight into
  # `grep -q` reports failure whenever grep exits before the writer is done.
  runtimes="$(xcrun simctl list runtimes 2>/dev/null || true)"

  if ! xcodebuild -license check >/dev/null 2>&1; then
    needs "Xcode license not accepted — run 'sudo xcodebuild -license accept', then re-run 'laboot setup-ios'."
  elif ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
    needs "Xcode first-launch tasks are pending — run 'sudo xcodebuild -runFirstLaunch', then re-run 'laboot setup-ios'."
  elif printf '%s\n' "$runtimes" | grep '^iOS' | grep -v 'unavailable' >/dev/null; then
    info "iOS simulator runtime already installed"
  else
    info "Downloading iOS simulator runtime (several GB, may take a while)..."
    if ! xcodebuild -downloadPlatform iOS; then
      needs "iOS simulator runtime download failed — re-run 'laboot setup-ios', or install it from Xcode > Settings > Components."
    fi
  fi
elif [ -d "/Applications/Xcode.app" ]; then
  needs "Xcode is installed but not selected — run 'sudo xcode-select -s /Applications/Xcode.app/Contents/Developer', then re-run 'laboot setup-ios'."
else
  needs "Full Xcode not found — install it from the App Store (needed for the iOS simulator):"
  warn "  https://apps.apple.com/app/xcode/id497799835"
  warn "Then re-run 'laboot setup-ios' to finish its setup and download the iOS platform."
fi

if [ "$pending" -eq 0 ]; then
  info "iOS tooling ready."
else
  warn "iOS tooling is not ready yet — follow the step above, then re-run 'laboot setup-ios'."
fi
