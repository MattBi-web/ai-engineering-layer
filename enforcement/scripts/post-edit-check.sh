#!/usr/bin/env bash
# Claude Code hook (PostToolUse / Edit|Write). Riceve JSON su stdin con il file modificato.
# Lancia un lint rapido sul SOLO file toccato (ruff per .py, eslint per .ts/.tsx) se disponibile.
# Non bloccante: stampa eventuali problemi come feedback, exit 0.
set -uo pipefail
input=$(cat)
file=$(printf '%s' "$input" | (jq -r '.tool_input.file_path // empty' 2>/dev/null || true))
[ -z "$file" ] || [ ! -f "$file" ] && exit 0

case "$file" in
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      out=$(ruff check "$file" 2>&1) || echo "⚠️ [lint] ruff su $file:"$'\n'"$out" >&2
    fi
    ;;
  *.ts|*.tsx)
    if command -v npx >/dev/null 2>&1 && [ -f package.json ]; then
      out=$(npx --no-install eslint "$file" 2>/dev/null) || { [ -n "$out" ] && echo "⚠️ [lint] eslint su $file:"$'\n'"$out" >&2; }
    fi
    ;;
esac
exit 0
