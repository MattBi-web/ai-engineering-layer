#!/usr/bin/env bash
# Claude Code hook (PreToolUse / Bash). Receives JSON on stdin with the proposed command.
# Blocks (exit 2) destructive commands. Otherwise exit 0.
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | (jq -r '.tool_input.command // empty' 2>/dev/null || sed -E 's/.*"command"\s*:\s*"([^"]*)".*/\1/'))
[ -z "$cmd" ] && exit 0

block() { echo "⛔ [guardrail] command blocked: $1" >&2; exit 2; }
case "$cmd" in
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf ."*) block "dangerous rm -rf" ;;
esac
echo "$cmd" | grep -qiE 'git +push +.*(--force|-f)\b'              && block "forced git push"
echo "$cmd" | grep -qiE '\bgit +reset +--hard +origin'             && block "reset --hard to remote"
echo "$cmd" | grep -qiE '\bdrop +(table|database|schema)\b'        && block "DROP on DB"
echo "$cmd" | grep -qiE 'truncate +table'                          && block "TRUNCATE"
echo "$cmd" | grep -qiE '\bsudo\b'                                 && block "sudo"
echo "$cmd" | grep -qiE ':\(\)\{ *:\|:& *\};:'                     && block "fork bomb"
exit 0
