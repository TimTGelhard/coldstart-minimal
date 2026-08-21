#!/usr/bin/env bash
# coldstart-minimal installer. One command, idempotent, reversible.
# Usage:  ./install.sh [target-dir]        install into a project (default: cwd)
#         ./install.sh --uninstall [dir]   remove the harness, keep your notes
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)/template"
MODE=install
if [ "${1:-}" = "--uninstall" ]; then MODE=uninstall; shift; fi
DEST="$(cd "${1:-$PWD}" && pwd)"

# Yours once written; the installer never overwrites or deletes these.
NOTES="CLAUDE.md PROGRESS.md DECISIONS.md"
# The harness itself; safe to overwrite on upgrade, safe to delete on uninstall.
HARNESS=".claude/hooks/floor.sh .claude/hooks/session-start.sh .claude/commands/done.md"

if [ "$MODE" = uninstall ]; then
  for f in $HARNESS; do rm -f "$DEST/$f"; done
  rm -f "$DEST/.claude/settings.coldstart.json"
  rmdir "$DEST/.claude/hooks" "$DEST/.claude/commands" 2>/dev/null || true
  echo "removed the harness from $DEST"
  echo "kept: $NOTES, and .claude/settings.json (unregister the two hooks by hand)"
  exit 0
fi

mkdir -p "$DEST/.claude/hooks" "$DEST/.claude/commands"

for f in $NOTES; do
  if [ -e "$DEST/$f" ]; then
    echo "kept    $f (already yours)"
  else
    cp "$SRC/$f" "$DEST/$f"; echo "wrote   $f"
  fi
done

for f in $HARNESS; do
  cp "$SRC/$f" "$DEST/$f"; echo "wrote   $f"
done
chmod +x "$DEST/.claude/hooks/"*.sh

if [ -e "$DEST/.claude/settings.json" ]; then
  cp "$SRC/.claude/settings.json" "$DEST/.claude/settings.coldstart.json"
  echo "kept    .claude/settings.json (yours)"
  echo "wrote   .claude/settings.coldstart.json - merge its two hook blocks into yours"
else
  cp "$SRC/.claude/settings.json" "$DEST/.claude/settings.json"; echo "wrote   .claude/settings.json"
fi

# The floor refuses to stage a .env, but the durable stop is git's own. A hook
# can be unregistered; a .gitignore line travels with the repo and protects the
# operator's own hands as well as the model's.
if [ -e "$DEST/.gitignore" ]; then
  if grep -Eqs '^!?\*?\.env' "$DEST/.gitignore"; then
    echo "kept    .gitignore (already ignores .env)"
  else
    printf '\n# coldstart-minimal: secrets never reach a remote\n.env\n.env.*\n!.env.example\n' >> "$DEST/.gitignore"
    echo "wrote   .gitignore (appended the .env rules)"
  fi
else
  printf '# coldstart-minimal: secrets never reach a remote\n.env\n.env.*\n!.env.example\n' > "$DEST/.gitignore"
  echo "wrote   .gitignore"
fi

resident=$(( $(wc -c < "$DEST/CLAUDE.md") + 78 ))
echo
echo "installed into $DEST"
echo "resident cost: ~${resident} B of harness, read at every session start"
echo "next: open CLAUDE.md, fill in the 'You' section, then start a session"
