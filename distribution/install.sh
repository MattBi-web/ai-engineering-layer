#!/usr/bin/env bash
# AI Engineering Layer — one-liner installer.
#
# Usage (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.sh | bash
#
# Idempotent: safe to re-run. Everything is optional except the agent-skills plugin + codebase-memory MCP.
# Opt-in: Obsidian (personal vault), nightly re-indexing routine (macOS launchd).
#
# Flags:
#   --with-obsidian /path/to/vault   enable the Obsidian MCP server on the given vault
#   --with-reindex-routine           install the nightly launchd job (macOS only)
#   --framework-dir /path            where to clone the framework template (default: ~/Dev/ai-engineering-layer)
#   --dry-run                        show what would be done, without changing anything
#   --help                           this text

set -euo pipefail

# ===== Config (override via env vars) =====
REPO_URL="${REPO_URL:-https://github.com/MattBi-web/ai-engineering-layer.git}"  # ← change OWNER before publishing
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
    *) echo "unknown flag: $1" >&2; exit 2 ;;
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
  - agent-skills plugin (process: /spec /plan /build /test /review /ship + 28 skills)
  - codebase-memory MCP (code knowledge graph → fewer tokens, fewer hallucinations)
  - "graph-first" rule and model routing (opusplan)
  - framework template (3 enforcement rings, layers, governance)
  - optional: Obsidian (long-term memory), nightly re-indexing routine
================================================================
BANNER

# ===== Prerequisites =====
say "Checking prerequisites"
need() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1 — install it and retry" >&2; exit 1; }; }
need claude; need node; need npm; need git; need jq
ok "claude $(claude --version 2>/dev/null | head -1) · node $(node -v) · npm $(npm -v) · git ok · jq ok"

# ===== 1) agent-skills plugin (idempotent) =====
say "Installing the agent-skills plugin (Addy Osmani, MIT)"
if claude plugin list 2>/dev/null | grep -q 'agent-skills@addy-agent-skills'; then
  ok "plugin already installed"
else
  run "claude plugin marketplace add addyosmani/agent-skills"
  run "claude plugin install agent-skills@addy-agent-skills"
  ok "agent-skills plugin installed"
fi

# ===== 2) codebase-memory MCP =====
say "Installing codebase-memory-mcp (binary, ~250MB)"
if command -v codebase-memory-mcp >/dev/null 2>&1; then
  ok "binary already present at $(command -v codebase-memory-mcp)"
else
  run "npm install -g codebase-memory-mcp"
fi
say "Registering the codebase-memory MCP server"
if claude mcp list 2>/dev/null | grep -q '^codebase-memory:'; then
  ok "MCP server already registered"
else
  run "claude mcp add codebase-memory -- $(command -v codebase-memory-mcp || echo codebase-memory-mcp)"
fi

# ===== 3) (optional) Obsidian =====
if [ -n "$WITH_OBSIDIAN" ]; then
  say "Configuring the Obsidian MCP server on vault: $WITH_OBSIDIAN"
  if [ ! -d "$WITH_OBSIDIAN" ]; then
    warn "path '$WITH_OBSIDIAN' does not exist — creating it (empty vault)"
    run "mkdir -p '$WITH_OBSIDIAN'"
  fi
  # minimal .obsidian config if missing (obsidian-mcp validates the vault)
  if [ ! -d "$WITH_OBSIDIAN/.obsidian" ]; then
    run "mkdir -p '$WITH_OBSIDIAN/.obsidian'"
    for j in app appearance hotkeys; do run "echo '{}' > '$WITH_OBSIDIAN/.obsidian/$j.json'"; done
    run "echo '[]' > '$WITH_OBSIDIAN/.obsidian/community-plugins.json'"
    run "echo '{}' > '$WITH_OBSIDIAN/.obsidian/core-plugins.json'"
  fi
  if ! claude mcp list 2>/dev/null | grep -q '^obsidian:'; then
    run "claude mcp add obsidian -- npx -y obsidian-mcp '$WITH_OBSIDIAN'"
  fi
  ok "Obsidian MCP active on vault $WITH_OBSIDIAN"
else
  warn "Obsidian not configured (re-run with --with-obsidian /path/to/vault if you want it)"
fi

# ===== 4) ~/.claude/settings.json (safe merge) =====
say "Updating ~/.claude/settings.json (opusplan model + read-only permissions, non-destructive merge)"
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
  echo "[dry-run] merge settings.json (model=opusplan, permissions.allow ⊕ read-only allowlist)"
else
  tmp=$(mktemp)
  jq --argjson allow "$ALLOW" '
    .model = (.model // "opusplan")
    | .permissions = (.permissions // {})
    | .permissions.allow = ((.permissions.allow // []) + $allow | unique)
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
fi
ok "settings.json updated (your existing keys preserved)"

# ===== 5) ~/.claude/CLAUDE.md (graph-first + model routing) =====
say "Updating ~/.claude/CLAUDE.md (graph-first rule + subagent routing)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARK_BEGIN="<!-- ai-engineering-layer: begin -->"
MARK_END="<!-- ai-engineering-layer: end -->"
BLOCK="$MARK_BEGIN
## Code: use the knowledge graph BEFORE grep/reading files
The \`codebase-memory\` MCP server is active. In indexed projects (\`list_projects\`) use the graph
tools FIRST (\`search_graph\`, \`search_code\`, \`trace_path\`, \`get_code_snippet\`,
\`get_architecture\`); fall back to grep only when the project isn't in the graph or you need exact text.

## Knowledge in Obsidian (if configured)
MCP server \`obsidian\` (personal vault): \`search-vault\`/\`read-note\` for ADRs, decisions, conventions.

## Model selection (cost-based routing)
Default \`opusplan\`. When delegating via Agent: \`haiku\` for search/lookup, \`sonnet\` for impl/tests,
\`opus\` for architecture/deep analysis. Grunt work goes to cheaper models.
$MARK_END"
if [ "$DRY_RUN" = "1" ]; then
  echo "[dry-run] writing/updating marked block in $CLAUDE_MD"
else
  if [ -f "$CLAUDE_MD" ] && grep -q "$MARK_BEGIN" "$CLAUDE_MD"; then
    # replace the block between the markers
    awk -v b="$MARK_BEGIN" -v e="$MARK_END" -v rep="$BLOCK" '
      $0 ~ b {print rep; skip=1; next} skip && $0 ~ e {skip=0; next} !skip
    ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  else
    printf "\n%s\n" "$BLOCK" >> "$CLAUDE_MD"
  fi
fi
ok "CLAUDE.md updated (marked block, safe to re-run)"

# ===== 6) Clone the framework template =====
say "Cloning the framework template into $FW_DIR"
if [ -d "$FW_DIR/.git" ]; then
  ok "already present — updating"
  run "git -C '$FW_DIR' pull --ff-only || true"
else
  run "git clone --depth 1 '$REPO_URL' '$FW_DIR'"
fi
ok "framework template available at $FW_DIR (drop the files into a target repo to enable the 3 rings)"

# ===== 7) (optional, macOS) Nightly re-indexing routine =====
if [ "$WITH_REINDEX" = "1" ]; then
  if [ "$(uname)" != "Darwin" ]; then
    warn "--with-reindex-routine is macOS only (launchd). Skipped."
  else
    say "Installing the nightly launchd re-indexing routine (03:17)"
    mkdir -p "$HOME/.claude/scripts" "$HOME/.claude/logs" "$HOME/Library/LaunchAgents"
    cp "$FW_DIR/distribution/reindex_codebase_memory.sh" "$HOME/.claude/scripts/" 2>/dev/null || \
      curl -fsSL "${REPO_URL%.git}/raw/master/distribution/reindex_codebase_memory.sh" \
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
    ok "nightly routine installed (logs in ~/.claude/logs)"
  fi
else
  warn "Re-indexing routine not installed (re-run with --with-reindex-routine to enable it)"
fi

# ===== 8) Summary =====
cat <<EOF

================================================================
✔ Setup complete. What you have now (restart Claude Code to load the plugin):
  • /spec /plan /build /test /review /ship  (agent-skills, 28 skills)
  • MCP codebase-memory   →   list_projects · search_graph · trace_path · get_architecture · …
$( [ -n "$WITH_OBSIDIAN" ] && echo "  • MCP obsidian        →   search-vault · read-note" )
  • Default model: opusplan (Opus for planning, Sonnet for execution)
  • Graph-first rule in ~/.claude/CLAUDE.md (graph before grep)
  • Framework template:    $FW_DIR
$( [ "$WITH_REINDEX" = "1" ] && echo "  • Nightly re-indexing routine: 03:17 (~/.claude/scripts/reindex_codebase_memory.sh)" )

To enable the 3 enforcement rings on ONE target repo:
  cd <repo>
  cp $FW_DIR/.github/PULL_REQUEST_TEMPLATE.md .github/
  cp $FW_DIR/.github/workflows/non-negotiables.yml .github/workflows/
  cp -r $FW_DIR/enforcement enforcement/
  cp $FW_DIR/enforcement/.pre-commit-config.yaml .pre-commit-config.yaml
  pre-commit install
  # then index the repo via the "index_repository" MCP tool

Quick uninstall: claude plugin uninstall agent-skills · claude mcp remove codebase-memory
================================================================
EOF
