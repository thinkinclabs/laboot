#!/usr/bin/env bash
# setup-native.sh (mac) — meta-command for the native mobile suite: Android
# (adb + Android Studio + emulator env) then iOS (Xcode CLT + watchman +
# CocoaPods). Both are idempotent, so this is too.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

laboot setup-android
laboot setup-ios
