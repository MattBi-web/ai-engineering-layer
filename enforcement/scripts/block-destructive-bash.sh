#!/usr/bin/env bash
# Claude Code hook (PreToolUse / Bash). Riceve JSON su stdin con il comando proposto.
# Blocca (exit 2) comandi distruttivi. Altrimenti exit 0.
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | (jq -r '.tool_input.command // empty' 2>/dev/null || sed -E 's/.*"command"\s*:\s*"([^"]*)".*/\1/'))
[ -z "$cmd" ] && exit 0

block() { echo "⛔ [guardrail] comando bloccato: $1" >&2; exit 2; }
case "$cmd" in
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf ."*) block "rm -rf pericoloso" ;;
esac
echo "$cmd" | grep -qiE 'git +push +.*(--force|-f)\b'              && block "git push forzato"
echo "$cmd" | grep -qiE '\bgit +reset +--hard +origin'             && block "reset --hard su remote"
echo "$cmd" | grep -qiE '\bdrop +(table|database|schema)\b'        && block "DROP su DB"
echo "$cmd" | grep -qiE 'truncate +table'                          && block "TRUNCATE"
echo "$cmd" | grep -qiE '\bsudo\b'                                 && block "sudo"
echo "$cmd" | grep -qiE ':\(\)\{ *:\|:& *\};:'                     && block "fork bomb"
exit 0
