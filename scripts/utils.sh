#!/usr/bin/env bash
# utils.sh (linux) — shared helpers for laboot and its commands. Sourced
# remotely (never a local file, same as every other laboot script), so
# every command gets these for free without duplicating them.

info() { printf '\033[1;34m[laboot]\033[0m %s\n' "$1"; }
