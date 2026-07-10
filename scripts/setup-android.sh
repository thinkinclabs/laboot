#!/usr/bin/env bash
# setup-android.sh (mac) — Android tooling for native dev: adb (platform
# tools) and Android Studio (SDK manager + emulator), plus ANDROID_HOME and
# PATH persisted to your shell rc. Idempotent. Enough to run
# `adb reverse tcp:8080 tcp:8080` against an attached device and to
# create/run an emulator from Android Studio's Device Manager. The SDK
# itself (and the emulator binaries) are downloaded by Android Studio's
# first-launch wizard — that part needs a GUI and can't run unattended.

set -euo pipefail

BRANCH="mac"
REPO="thinkinclabs/laboot"
MARKER="# >>> android >>>"
MARKER_END="# <<< android <<<"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }
warn() { printf '\033[1;33m[laboot]\033[0m %s\n' "$1" >&2; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
  export PATH="$HOME/.local/bin:$PATH"
fi

laboot setup-brew

if command -v adb >/dev/null 2>&1; then
  info "adb already installed"
else
  info "Installing Android platform-tools (adb)..."
  brew install --cask android-platform-tools
fi

if [ -d "/Applications/Android Studio.app" ]; then
  info "Android Studio already installed"
else
  info "Installing Android Studio..."
  brew install --cask android-studio
fi

# Persist ANDROID_HOME and put the SDK's own platform-tools/emulator first
# on PATH — once Android Studio downloads the SDK, its adb takes precedence
# over the Homebrew one, avoiding version-mismatch adb server restarts.
persist() {
  local rc="$1"
  [ -e "$rc" ] || return 1
  if grep -qF "$MARKER" "$rc" 2>/dev/null; then
    local tmp; tmp="$(mktemp)"
    sed "/$(printf '%s' "$MARKER" | sed 's/[][\.*^$/]/\\&/g')/,/$(printf '%s' "$MARKER_END" | sed 's/[][\.*^$/]/\\&/g')/d" "$rc" > "$tmp" && cat "$tmp" > "$rc" && rm -f "$tmp"
  fi
  {
    printf '%s\n' "$MARKER"
    printf '%s\n' 'export ANDROID_HOME="$HOME/Library/Android/sdk"'
    printf '%s\n' 'export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"'
    printf '%s\n' "$MARKER_END"
  } >> "$rc"
  info "Persisted ANDROID_HOME to $rc"
}

persisted=0
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if persist "$rc"; then persisted=1; fi
done

if [ "$persisted" -eq 0 ]; then
  warn "Could not write to a shell rc file. Add these lines manually:"
  printf '\n    export ANDROID_HOME="$HOME/Library/Android/sdk"\n    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"\n\n'
fi

info "Android tooling ready. Next steps:"
info "  1. Open Android Studio once — its setup wizard downloads the SDK + emulator."
info "  2. Device Manager > Create Virtual Device to get an emulator."
info "  3. With a device/emulator attached: adb reverse tcp:8080 tcp:8080"
