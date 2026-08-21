#!/usr/bin/env bash
# SessionStart. Prints the active work block from PROGRESS.md and nothing else.
#
# The boundary is a marker, not a line count, so a block can be any length. The
# `head` is a backstop, not the mechanism: it only bites if someone writes an essay
# above the marker or deletes the marker entirely.
set -u
f="${CLAUDE_PROJECT_DIR:-$PWD}/PROGRESS.md"
[ -f "$f" ] || exit 0
sed -n '1,/^---$/p' "$f" | sed '/^---$/d' | head -40
