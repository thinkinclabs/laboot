#!/usr/bin/env bash
# setup-obsidian.sh (windows) — installs/refreshes kepano/obsidian-skills
# into labrain's ./.claude (sibling of labrain-vault). Idempotent. Runs
# under Git Bash — invoked by setup-obsidian.ps1, never directly on native
# PowerShell.
#
# Resolves $LABRAIN_PATH by sourcing setup-labrain.sh, not by calling
# `laboot setup-labrain` as a subprocess — a subprocess's `export
# LABRAIN_PATH` never reaches back to this shell, but sourcing runs it
# directly here.

set -euo pipefail

BRANCH="windows"
REPO="thinkinclabs/laboot"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }
warn() { printf '\033[1;33m[laboot]\033[0m %s\n' "$1" >&2; }

if [ -z "${LABRAIN_PATH:-}" ] || [ ! -d "$LABRAIN_PATH/labrain-vault" ]; then
  _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/setup-labrain.sh" -o "$_u" && source "$_u" && rm -f "$_u"
fi

SKILLS_REPO="https://github.com/kepano/obsidian-skills"
CLAUDE_DIR="$LABRAIN_PATH/.claude"
mkdir -p "$CLAUDE_DIR"

info "Installing obsidian-skills into $CLAUDE_DIR/skills"

if command -v npx >/dev/null 2>&1; then
  ( cd "$LABRAIN_PATH" && npx --yes skills add "$SKILLS_REPO" ) && {
    info "Installed via npx skills."
    exit 0
  }
  warn "npx skills failed; falling back to git clone."
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
if git clone --depth 1 "$SKILLS_REPO" "$TMP/obsidian-skills" >/dev/null 2>&1; then
  mkdir -p "$CLAUDE_DIR/skills"
  cp -R "$TMP/obsidian-skills/skills/." "$CLAUDE_DIR/skills/"
  info "Installed via git clone fallback."
else
  warn "Could not install obsidian-skills automatically."
  warn "Install manually inside Claude Code:  /plugin marketplace add kepano/obsidian-skills"
  exit 1
fi
