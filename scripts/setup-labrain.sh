#!/usr/bin/env bash
# setup-labrain.sh (windows) — clones labrain (private repo) if needed and
# persists $LABRAIN_PATH to your shell rc. Idempotent. Runs under Git Bash —
# invoked by setup-labrain.ps1, never directly on native PowerShell. The
# vault is ALWAYS "$LABRAIN_PATH/labrain-vault" — no separate variable.
#
# Depends on the setup-gh command, run through laboot itself — every
# prerequisite a command needs goes through `laboot <name>`, never a
# hand-rolled fetch, so there is one dependency mechanism, not two. This
# used to fetch and run a copy of this logic that lived in the labrain repo
# itself; it now lives here instead, so labrain's own copy is just a thin
# wrapper around `laboot setup-labrain`.

set -euo pipefail

BRANCH="windows"
REPO="thinkinclabs/laboot"
REPO_URL="https://github.com/thinkinclabs/labrain.git"
REPO_NAME="labrain"
MARKER="# >>> labrain >>>"
MARKER_END="# <<< labrain <<<"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }
warn() { printf '\033[1;33m[laboot]\033[0m %s\n' "$1" >&2; }

if ! command -v laboot >/dev/null 2>&1; then
  bash <(curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh")
fi

info "Ensuring GitHub CLI is ready..."
laboot setup-gh

resolve_path() {
  if [ -n "${LABRAIN_PATH:-}" ] && [ -d "$LABRAIN_PATH/labrain-vault" ]; then
    echo "$LABRAIN_PATH"; return 0
  fi

  local base
  base="$(pwd)"
  for cand in "$base/$REPO_NAME" "$base/../$REPO_NAME" "$base/../../$REPO_NAME"; do
    if [ -d "$cand/labrain-vault" ]; then
      (cd "$cand" && pwd); return 0
    fi
  done

  local target="$base/../$REPO_NAME"
  info "labrain not found locally; cloning into $(cd "$base/.." && pwd)/$REPO_NAME"
  git clone "$REPO_URL" "$target" >/dev/null 2>&1 || {
    warn "git clone failed. This repo is private — run 'gh auth login', then retry: git clone $REPO_URL"; return 1
  }
  (cd "$target" && pwd)
}

LABRAIN_PATH="$(resolve_path)" || exit 1
export LABRAIN_PATH
info "LABRAIN_PATH = $LABRAIN_PATH"

# Also set it as a real Windows User env var (setx), not just in Git Bash's
# own .bashrc — visible to native PowerShell/cmd and to agents that never
# touch Git Bash, not just this shell.
if command -v setx >/dev/null 2>&1; then
  setx LABRAIN_PATH "$(cygpath -w "$LABRAIN_PATH" 2>/dev/null || echo "$LABRAIN_PATH")" >/dev/null 2>&1 \
    && info "Also set LABRAIN_PATH as a Windows User environment variable" \
    || warn "Could not set LABRAIN_PATH via setx — set it manually if you need it outside Git Bash"
fi

persist() {
  local rc="$1"
  [ -e "$rc" ] || return 1
  if grep -qF "$MARKER" "$rc" 2>/dev/null; then
    local tmp; tmp="$(mktemp)"
    sed "/$(printf '%s' "$MARKER" | sed 's/[][\.*^$/]/\\&/g')/,/$(printf '%s' "$MARKER_END" | sed 's/[][\.*^$/]/\\&/g')/d" "$rc" > "$tmp" && cat "$tmp" > "$rc" && rm -f "$tmp"
  fi
  {
    printf '%s\n' "$MARKER"
    printf 'export LABRAIN_PATH="%s"\n' "$LABRAIN_PATH"
    printf '%s\n' "$MARKER_END"
  } >> "$rc"
  info "Persisted LABRAIN_PATH to $rc"
}

persisted=0
for rc in "$HOME/.bashrc"; do
  if persist "$rc"; then persisted=1; fi
done

if [ "$persisted" -eq 0 ]; then
  warn "Could not write to Git Bash's ~/.bashrc. Add this line manually:"
  printf '\n    export LABRAIN_PATH="%s"\n\n' "$LABRAIN_PATH"
fi

info "Open a new terminal (Git Bash or native) so LABRAIN_PATH is available there."

info "Done. The vault is at: $LABRAIN_PATH/labrain-vault"
