#!/usr/bin/env bash
# Re-indicizza tutti i progetti presenti nel knowledge graph di codebase-memory-mcp.
# Self-maintaining: legge i progetti correnti via `cli list_projects` e re-indicizza
# ciascuna root ancora esistente. Pensato per essere lanciato da launchd (notturno).
# Portabile: nessun path hardcoded (usa $HOME e $PATH).

BIN="$(command -v codebase-memory-mcp || echo /opt/homebrew/bin/codebase-memory-mcp)"
LOGDIR="$HOME/.claude/logs"
LOG="$LOGDIR/codebase-memory-reindex.log"
mkdir -p "$LOGDIR"

echo "===== reindex $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOG"

if [ ! -x "$BIN" ]; then
  echo "[error] binario non trovato: $BIN (installa con: npm i -g codebase-memory-mcp)" >> "$LOG"
  exit 1
fi

"$BIN" cli list_projects 2>/dev/null | grep '^{' | jq -r '.projects[].root_path' | while IFS= read -r root; do
  if [ -d "$root" ]; then
    echo "[reindex] $root" >> "$LOG"
    payload="$(jq -nc --arg p "$root" '{repo_path:$p, mode:"full"}')"
    "$BIN" cli index_repository "$payload" >> "$LOG" 2>&1
    echo "" >> "$LOG"
  else
    echo "[skip-missing] $root" >> "$LOG"
  fi
done

echo "done $(date '+%H:%M:%S')" >> "$LOG"
