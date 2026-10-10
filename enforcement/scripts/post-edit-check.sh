#!/usr/bin/env bash
# Claude Code hook (PostToolUse / Edit|Write). Receives JSON on stdin with the modified file.
# Runs a quick lint on ONLY the touched file (ruff for .py, eslint for .ts/.tsx) if available.
# Non-blocking: prints any issues as feedback, exit 0.
set -uo pipefail
input=$(cat)
file=$(printf '%s' "$input" | (jq -r '.tool_input.file_path // empty' 2>/dev/null || true))
[ -z "$file" ] || [ ! -f "$file" ] && exit 0

case "$file" in
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      out=$(ruff check "$file" 2>&1) || echo "⚠️ [lint] ruff on $file:"$'\n'"$out" >&2
    fi
    ;;
  *.ts|*.tsx)
    if command -v npx >/dev/null 2>&1 && [ -f package.json ]; then
      out=$(npx --no-install eslint "$file" 2>/dev/null) || { [ -n "$out" ] && echo "⚠️ [lint] eslint on $file:"$'\n'"$out" >&2; }
    fi
    ;;
esac
exit 0
