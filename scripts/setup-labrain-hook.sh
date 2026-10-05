#!/usr/bin/env bash
# setup-labrain-hook.sh (windows) — installs the Claude Code SessionStart hook that
# keeps the local labrain clone current, into the user-level settings
# (~/.claude/settings.json) so it fires for every repo on this machine, not
# just sessions opened inside labrain. Runs under Git Bash —
# invoked by setup-labrain-hook.ps1, never directly on native PowerShell.
#
# The hook runs labrain's own scripts/update-brain.sh: a fast-forward-only
# pull that skips itself when local edits or unpushed commits are in the way.
# All the pull logic lives there; this command only wires it.
#
# Idempotent: re-running replaces the previous entry instead of adding a
# second one, leaves every other hook and setting untouched, and writes a
# backup next to the file the first time it actually changes it. Run after
# `laboot setup-labrain` (it needs $LABRAIN_PATH).

set -euo pipefail

BRANCH="windows"
REPO="thinkinclabs/laboot"
HOOK_SCRIPT="scripts/update-brain.sh"

declare -f info >/dev/null 2>&1 || { _u=$(mktemp) && curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/utils.sh" -o "$_u" && source "$_u" && rm -f "$_u"; }
warn() { printf '\033[1;33m[laboot]\033[0m %s\n' "$1" >&2; }

# setup-labrain persists LABRAIN_PATH to the shell rc, which a process that
# was already running (e.g. `laboot setup` chaining both) never re-reads —
# fall back to the line it wrote there.
if [ -z "${LABRAIN_PATH:-}" ]; then
  for rc in "$HOME/.bashrc"; do
    [ -e "$rc" ] || continue
    LABRAIN_PATH="$(sed -n 's/^export LABRAIN_PATH="\(.*\)"$/\1/p' "$rc" | tail -n 1)"
    [ -n "$LABRAIN_PATH" ] && break
  done
fi

# LABRAIN_PATH and CLAUDE_CONFIG_DIR arrive in Windows form (C:\...) when they
# come from the User environment; Git Bash wants its own form to test paths.
to_unix() { cygpath -u "$1" 2>/dev/null || printf '%s' "$1"; }
[ -n "${LABRAIN_PATH:-}" ] && LABRAIN_PATH="$(to_unix "$LABRAIN_PATH")"
SETTINGS="$(to_unix "${CLAUDE_CONFIG_DIR:-$HOME/.claude}")/settings.json"

if [ -z "${LABRAIN_PATH:-}" ] || [ ! -d "$LABRAIN_PATH/labrain-vault" ]; then
  warn "LABRAIN_PATH is not set to a labrain clone. Run 'laboot setup-labrain', open a new terminal, then retry."
  exit 1
fi

if [ ! -f "$LABRAIN_PATH/$HOOK_SCRIPT" ]; then
  warn "$LABRAIN_PATH/$HOOK_SCRIPT is missing. Update labrain (git -C \"$LABRAIN_PATH\" pull), then retry."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  warn "jq is not on PATH. Install it (winget install jqlang.jq), open a new terminal, then retry."
  exit 1
fi

mkdir -p "$(dirname "$SETTINGS")"
[ -s "$SETTINGS" ] || printf '{}\n' > "$SETTINGS"

if ! jq empty "$SETTINGS" >/dev/null 2>&1; then
  warn "$SETTINGS is not valid JSON; leaving it untouched. Fix it, then retry."
  exit 1
fi

# Claude Code runs hooks through Git Bash on Windows, so the hook is the same
# bash script, called through bash explicitly. $LABRAIN_PATH from the
# session's environment wins; the path resolved now (in C:/ form, which both
# Git Bash and JSON take as is) is the fallback.
fallback="$(cygpath -m "$LABRAIN_PATH" 2>/dev/null || printf '%s' "$LABRAIN_PATH")"
command="bash \"\${LABRAIN_PATH:-$fallback}/$HOOK_SCRIPT\""

updated="$(mktemp)"
jq --arg command "$command" --arg marker "$HOOK_SCRIPT" '
  .hooks //= {}
  | .hooks.SessionStart //= []
  | .hooks.SessionStart |= (
      map(.hooks = ((.hooks // []) | map(select(((.command // "") | contains($marker)) | not))))
      | map(select((.hooks | length) > 0))
    )
  | .hooks.SessionStart += [
      {
        hooks: [
          {
            type: "command",
            command: $command,
            timeout: 30,
            statusMessage: "Updating labrain..."
          }
        ]
      }
    ]
' "$SETTINGS" > "$updated"

if cmp -s "$updated" "$SETTINGS"; then
  rm -f "$updated"
  info "labrain SessionStart hook already installed in $SETTINGS"
  exit 0
fi

cp "$SETTINGS" "$SETTINGS.laboot-backup"
cat "$updated" > "$SETTINGS"
rm -f "$updated"

info "Installed the labrain SessionStart hook in $SETTINGS (backup: $SETTINGS.laboot-backup)"
info "New Claude Code sessions pick it up; in a running one, open /hooks once or restart."
