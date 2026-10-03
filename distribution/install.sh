#!/usr/bin/env bash
# AI Engineering Layer — installer one-liner.
#
# Uso (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.sh | bash
#
# Idempotente: re-eseguibile in sicurezza. Tutto opzionale tranne plugin agent-skills + codebase-memory MCP.
# Opt-in: Obsidian (vault personale), routine di re-indexing notturno (macOS launchd).
#
# Flag:
#   --with-obsidian /path/to/vault   abilita il server MCP Obsidian sul vault indicato
#   --with-reindex-routine           installa il job launchd notturno (solo macOS)
#   --framework-dir /path            dove clonare il template del framework (default: ~/Dev/ai-engineering-layer)
#   --dry-run                        mostra cosa farebbe, senza modificare nulla
#   --help                           questo testo

set -euo pipefail

# ===== Config (override via env vars) =====
REPO_URL="${REPO_URL:-https://github.com/MattBi-web/ai-engineering-layer.git}"  # ← cambia OWNER prima di pubblicare
DEFAULT_FW_DIR="${HOME}/Dev/ai-engineering-layer"
WITH_OBSIDIAN=""
WITH_REINDEX="0"
FW_DIR=""
DRY_RUN="0"

# ===== Args =====
while [ $# -gt 0 ]; do
  case "$1" in
    --with-obsidian)        WITH_OBSIDIAN="${2:-}"; shift 2 ;;
    --with-reindex-routine) WITH_REINDEX="1"; shift ;;
    --framework-dir)        FW_DIR="${2:-}"; shift 2 ;;
    --dry-run)              DRY_RUN="1"; shift ;;
    -h|--help)              sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "flag sconosciuto: $1" >&2; exit 2 ;;
  esac
done
FW_DIR="${FW_DIR:-$DEFAULT_FW_DIR}"

run() { if [ "$DRY_RUN" = "1" ]; then echo "[dry-run] $*"; else eval "$@"; fi; }
say() { printf "\033[1;36m▶ %s\033[0m\n" "$*"; }
ok()  { printf "\033[1;32m✔ %s\033[0m\n" "$*"; }
warn(){ printf "\033[1;33m! %s\033[0m\n" "$*"; }

# ===== Banner =====
cat <<'BANNER'
================================================================
  AI Engineering Layer — installer
  - plugin agent-skills (processo: /spec /plan /build /test /review /ship + 28 skill)
  - MCP codebase-memory (knowledge graph del codice → -token e -allucinazioni)
  - regola "graph-first" e model routing (opusplan)
  - template del framework (3 cordoni di enforcement, layer, governance)
  - opzionale: Obsidian (memoria lungo termine), routine notturna di re-indicizzazione
================================================================
BANNER

# ===== Prerequisiti =====
say "Verifico prerequisiti"
need() { command -v "$1" >/dev/null 2>&1 || { echo "manca: $1 — installalo e riprova" >&2; exit 1; }; }
need claude; need node; need npm; need git; need jq
ok "claude $(claude --version 2>/dev/null | head -1) · node $(node -v) · npm $(npm -v) · git ok · jq ok"

# ===== 1) Plugin agent-skills (idempotente) =====
say "Installo il plugin agent-skills (Addy Osmani, MIT)"
if claude plugin list 2>/dev/null | grep -q 'agent-skills@addy-agent-skills'; then
  ok "plugin già installato"
else
  run "claude plugin marketplace add addyosmani/agent-skills"
  run "claude plugin install agent-skills@addy-agent-skills"
  ok "plugin agent-skills installato"
fi

# ===== 2) codebase-memory MCP =====
say "Installo codebase-memory-mcp (binario, ~250MB)"
if command -v codebase-memory-mcp >/dev/null 2>&1; then
  ok "binario già presente in $(command -v codebase-memory-mcp)"
else
  run "npm install -g codebase-memory-mcp"
fi
say "Registro il server MCP codebase-memory"
if claude mcp list 2>/dev/null | grep -q '^codebase-memory:'; then
  ok "server MCP già registrato"
else
  run "claude mcp add codebase-memory -- $(command -v codebase-memory-mcp || echo codebase-memory-mcp)"
fi

# ===== 3) (opzionale) Obsidian =====
if [ -n "$WITH_OBSIDIAN" ]; then
  say "Configuro server MCP Obsidian sul vault: $WITH_OBSIDIAN"
  if [ ! -d "$WITH_OBSIDIAN" ]; then
    warn "il path '$WITH_OBSIDIAN' non esiste — lo creo (vault vuoto)"
    run "mkdir -p '$WITH_OBSIDIAN'"
  fi
  # config .obsidian minimale se mancante (obsidian-mcp valida il vault)
  if [ ! -d "$WITH_OBSIDIAN/.obsidian" ]; then
    run "mkdir -p '$WITH_OBSIDIAN/.obsidian'"
    for j in app appearance hotkeys; do run "echo '{}' > '$WITH_OBSIDIAN/.obsidian/$j.json'"; done
    run "echo '[]' > '$WITH_OBSIDIAN/.obsidian/community-plugins.json'"
    run "echo '{}' > '$WITH_OBSIDIAN/.obsidian/core-plugins.json'"
  fi
  if ! claude mcp list 2>/dev/null | grep -q '^obsidian:'; then
    run "claude mcp add obsidian -- npx -y obsidian-mcp '$WITH_OBSIDIAN'"
  fi
  ok "Obsidian MCP attivo sul vault $WITH_OBSIDIAN"
else
  warn "Obsidian non configurato (riavvia con --with-obsidian /path/to/vault se lo vuoi)"
fi

# ===== 4) ~/.claude/settings.json (merge sicuro) =====
say "Aggiorno ~/.claude/settings.json (modello opusplan + permessi read-only, merge non distruttivo)"
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
ALLOW='[
  "mcp__codebase-memory__search_graph","mcp__codebase-memory__trace_path",
  "mcp__codebase-memory__get_code_snippet","mcp__codebase-memory__get_graph_schema",
  "mcp__codebase-memory__get_architecture","mcp__codebase-memory__search_code",
  "mcp__codebase-memory__list_projects","mcp__codebase-memory__index_status",
  "mcp__obsidian__search-vault","mcp__obsidian__read-note","mcp__obsidian__list-available-vaults",
  "Bash(claude mcp list)"
]'
if [ "$DRY_RUN" = "1" ]; then
  echo "[dry-run] merge settings.json (model=opusplan, permissions.allow ⊕ allowlist read-only)"
else
  tmp=$(mktemp)
  jq --argjson allow "$ALLOW" '
    .model = (.model // "opusplan")
    | .permissions = (.permissions // {})
    | .permissions.allow = ((.permissions.allow // []) + $allow | unique)
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
fi
ok "settings.json aggiornato (preservate le tue chiavi esistenti)"

# ===== 5) ~/.claude/CLAUDE.md (graph-first + model routing) =====
say "Aggiorno ~/.claude/CLAUDE.md (regola graph-first + routing subagent)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARK_BEGIN="<!-- ai-engineering-layer: begin -->"
MARK_END="<!-- ai-engineering-layer: end -->"
BLOCK="$MARK_BEGIN
## Codice: usa il knowledge graph PRIMA di grep/lettura file
È attivo il server MCP \`codebase-memory\`. Nei progetti indicizzati (\`list_projects\`) usa PRIMA gli
strumenti del grafo (\`search_graph\`, \`search_code\`, \`trace_path\`, \`get_code_snippet\`,
\`get_architecture\`); fallback a grep solo quando il progetto non è nel grafo o serve testo esatto.

## Conoscenza in Obsidian (se configurato)
Server MCP \`obsidian\` (vault personale): \`search-vault\`/\`read-note\` per ADR, decisioni, convenzioni.

## Selezione del modello (routing per costo)
Default \`opusplan\`. Delegando via Agent: \`haiku\` per ricerche/lookup, \`sonnet\` per impl/test,
\`opus\` per architettura/analisi profonda. La manovalanza va su modelli economici.
$MARK_END"
if [ "$DRY_RUN" = "1" ]; then
  echo "[dry-run] scrivo/aggiorno blocco marcato in $CLAUDE_MD"
else
  if [ -f "$CLAUDE_MD" ] && grep -q "$MARK_BEGIN" "$CLAUDE_MD"; then
    # sostituisci il blocco fra i marker
    awk -v b="$MARK_BEGIN" -v e="$MARK_END" -v rep="$BLOCK" '
      $0 ~ b {print rep; skip=1; next} skip && $0 ~ e {skip=0; next} !skip
    ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  else
    printf "\n%s\n" "$BLOCK" >> "$CLAUDE_MD"
  fi
fi
ok "CLAUDE.md aggiornato (blocco fra marker, ri-eseguibile in sicurezza)"

# ===== 6) Clone del framework template =====
say "Clono il template framework in $FW_DIR"
if [ -d "$FW_DIR/.git" ]; then
  ok "già presente — aggiorno"
  run "git -C '$FW_DIR' pull --ff-only || true"
else
  run "git clone --depth 1 '$REPO_URL' '$FW_DIR'"
fi
ok "framework template disponibile in $FW_DIR (droppa i file dentro un repo target per attivare i 3 cordoni)"

# ===== 7) (opzionale, macOS) Routine notturna di re-indicizzazione =====
if [ "$WITH_REINDEX" = "1" ]; then
  if [ "$(uname)" != "Darwin" ]; then
    warn "--with-reindex-routine è solo macOS (launchd). Saltato."
  else
    say "Installo la routine launchd notturna (03:17) di re-indicizzazione"
    mkdir -p "$HOME/.claude/scripts" "$HOME/.claude/logs" "$HOME/Library/LaunchAgents"
    cp "$FW_DIR/distribution/reindex_codebase_memory.sh" "$HOME/.claude/scripts/" 2>/dev/null || \
      curl -fsSL "${REPO_URL%.git}/raw/main/distribution/reindex_codebase_memory.sh" \
           -o "$HOME/.claude/scripts/reindex_codebase_memory.sh"
    chmod +x "$HOME/.claude/scripts/reindex_codebase_memory.sh"
    cat > "$HOME/Library/LaunchAgents/com.aengl.reindex.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.aengl.reindex</string>
  <key>ProgramArguments</key><array>
    <string>/bin/bash</string><string>${HOME}/.claude/scripts/reindex_codebase_memory.sh</string>
  </array>
  <key>StartCalendarInterval</key><dict><key>Hour</key><integer>3</integer><key>Minute</key><integer>17</integer></dict>
  <key>StandardOutPath</key><string>${HOME}/.claude/logs/codebase-memory-reindex.launchd.log</string>
  <key>StandardErrorPath</key><string>${HOME}/.claude/logs/codebase-memory-reindex.launchd.log</string>
</dict></plist>
PLIST
    launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.aengl.reindex.plist" 2>/dev/null \
      || launchctl load -w "$HOME/Library/LaunchAgents/com.aengl.reindex.plist"
    ok "routine notturna installata (log in ~/.claude/logs)"
  fi
else
  warn "Routine re-indexing non installata (riavvia con --with-reindex-routine per attivarla)"
fi

# ===== 8) Riepilogo =====
cat <<EOF

================================================================
✔ Setup completato. Cosa hai ora (riavvia Claude Code per caricare il plugin):
  • /spec /plan /build /test /review /ship  (agent-skills, 28 skill)
  • MCP codebase-memory   →   list_projects · search_graph · trace_path · get_architecture · …
$( [ -n "$WITH_OBSIDIAN" ] && echo "  • MCP obsidian        →   search-vault · read-note" )
  • Modello default: opusplan (Opus in plan, Sonnet in esecuzione)
  • Regola graph-first in ~/.claude/CLAUDE.md (uso il grafo prima di grep)
  • Framework template:    $FW_DIR
$( [ "$WITH_REINDEX" = "1" ] && echo "  • Routine notturna di re-indicizzazione: 03:17 (~/.claude/scripts/reindex_codebase_memory.sh)" )

Per attivare i 3 cordoni di enforcement su UN repo target:
  cd <repo>
  cp $FW_DIR/.github/PULL_REQUEST_TEMPLATE.md .github/
  cp $FW_DIR/.github/workflows/non-negotiables.yml .github/workflows/
  cp -r $FW_DIR/enforcement enforcement/
  cp $FW_DIR/enforcement/.pre-commit-config.yaml .pre-commit-config.yaml
  pre-commit install
  # poi indicizza il repo via il tool MCP "index_repository"

Disinstallazione (al volo): claude plugin uninstall agent-skills · claude mcp remove codebase-memory
================================================================
EOF
