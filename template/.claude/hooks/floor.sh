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
