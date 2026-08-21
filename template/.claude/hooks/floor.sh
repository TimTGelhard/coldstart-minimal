#!/usr/bin/env bash
# PreToolUse safety floor. Deny-only: it never injects, it only refuses.
# Exit 2 blocks the tool call and returns stderr to the model.
set -u
payload="$(cat)"

case "$payload" in
  *'"tool_name":"Bash"'*|*'"tool_name": "Bash"'*) ;;
  *) exit 0 ;;
esac

deny() { printf 'coldstart floor: %s\n' "$1" >&2; exit 2; }

case "$payload" in
  *'rm -rf /'*|*'rm -fr /'*)
    deny 'refusing a recursive delete of a root path' ;;
esac

case "$payload" in
  *.env*)
    case "$payload" in
      *'cat '*|*'less '*|*'head '*|*'tail '*|*'echo '*|*'printf '*)
        deny 'refusing to print a .env file; secrets do not belong in a transcript' ;;
    esac ;;
esac

# Reading a .env is a local leak. Committing one is a public leak that survives
# the commit being deleted, because the object stays in forks, clones and caches.
case "$payload" in
  *'git add'*|*'git commit'*|*'git stash'*)
    case "$payload" in
      *.env.example*|*.env.sample*) ;;
      *.env*)
        deny 'refusing to stage a .env; a pushed secret stays public after the commit is deleted, and the fix is rotation. Put it in .gitignore, commit that, then stage the rest by name' ;;
    esac ;;
esac

# The accident that actually happens: nothing in the command names the file.
# Only fires while an unignored .env is really sitting there, so a clean tree
# never sees it.
case "$payload" in
  *'git add -A'*|*'git add --all'*|*'git add ."'*|*'git add . '*|*'git commit -a'*|*'git commit --all'*)
    if ! grep -Eqs '^!?\*?\.env' .gitignore; then
      for f in .env .env.*; do
        [ -f "$f" ] || continue
        case "$f" in *.example|*.sample|*.template) continue ;; esac
        deny "refusing to stage everything while $f is in the tree and not in .gitignore; ignore it and commit that first, or stage by name"
      done
    fi ;;
esac

case "$payload" in
  *curl*|*wget*)
    case "$payload" in
      *'| sh'*|*'|sh'*|*'| bash'*|*'|bash'*)
        deny 'refusing to pipe a download straight into a shell' ;;
    esac ;;
esac

case "$payload" in
  *'git push'*)
    case "$payload" in
      *'--force'*)
        deny 'refusing a force push; use --force-with-lease on purpose' ;;
    esac ;;
esac

exit 0
