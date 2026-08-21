#!/usr/bin/env bash
# SessionStart. Prints the pointer block from PROGRESS.md into the session.
# This is why there is no /coldstart command: the resume needs no typing.
set -u
f="${CLAUDE_PROJECT_DIR:-$PWD}/PROGRESS.md"
[ -f "$f" ] || exit 0
sed -n '/^## Now/,/^## Open/p' "$f" | sed '$d'
