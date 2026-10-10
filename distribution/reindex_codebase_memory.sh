#!/usr/bin/env bash
# Re-indexes every project in the codebase-memory-mcp knowledge graph.
# Self-maintaining: reads the current projects via `cli list_projects` and re-indexes
# each root that still exists. Meant to be launched by launchd (nightly).
# Portable: no hardcoded paths (uses $HOME and $PATH).

BIN="$(command -v codebase-memory-mcp || echo /opt/homebrew/bin/codebase-memory-mcp)"
LOGDIR="$HOME/.claude/logs"
LOG="$LOGDIR/codebase-memory-reindex.log"
mkdir -p "$LOGDIR"

echo "===== reindex $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOG"

if [ ! -x "$BIN" ]; then
  echo "[error] binary not found: $BIN (install with: npm i -g codebase-memory-mcp)" >> "$LOG"
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
