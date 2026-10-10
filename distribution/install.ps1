<#
AI Engineering Layer — Windows installer (PowerShell 5.1+ / 7+).

One-liner usage (basic mode, no arguments):
  irm https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.ps1 | iex

With arguments (Obsidian / Task Scheduler routine):
  irm <URL>/install.ps1 -OutFile install.ps1
  .\install.ps1 -WithObsidian "$HOME\Documents\Memoria_AI" -WithReindexRoutine

Idempotent. Never overwrites your existing settings — merges where needed.
Claude Code hooks (block-destructive-bash, etc.) need `bash` (Git Bash or WSL): if it's missing,
the install still works but the hooks will be disabled (you'll get a warning).
#>

[CmdletBinding()]
param(
  [string]$RepoUrl       = "https://github.com/MattBi-web/ai-engineering-layer.git",   # ← change OWNER before publishing
  [string]$FrameworkDir  = (Join-Path $HOME "Dev\ai-engineering-layer"),
  [string]$WithObsidian  = "",
  [switch]$WithReindexRoutine,
  [switch]$DryRun,
  [switch]$Help
)

if ($Help) {
  Get-Content $PSCommandPath | Select-Object -First 18 | ForEach-Object { ($_ -replace '^#?<#|#>?','').Trim() }
  exit 0
}

function Say  ($m){ Write-Host "▶ $m" -ForegroundColor Cyan }
function Ok   ($m){ Write-Host "✔ $m" -ForegroundColor Green }
function Warn ($m){ Write-Host "! $m" -ForegroundColor Yellow }
function Fail ($m){ Write-Host "✗ $m" -ForegroundColor Red; exit 1 }
function Run  ($cmd){ if ($DryRun){ Write-Host "[dry-run] $cmd" } else { Invoke-Expression $cmd } }

Write-Host @"
================================================================
  AI Engineering Layer — installer (Windows)
  - agent-skills plugin (/spec /plan /build /test /review /ship + 28 skills)
  - codebase-memory MCP (code knowledge graph)
  - graph-first rule + model routing (opusplan)
  - framework template (governance + enforcement + 12 layers)
  - optional: Obsidian, scheduled routine (Task Scheduler)
================================================================
"@ -ForegroundColor White

# ===== Prereq =====
Say "Checking prerequisites"
foreach ($cmd in @('claude','node','npm','git')) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Fail "missing: $cmd — install it and retry" }
}
$bashAvailable = [bool](Get-Command bash -ErrorAction SilentlyContinue)
if (-not $bashAvailable) { Warn "bash not found: Claude Code hooks (PreToolUse/Stop/...) require Git Bash or WSL. Everything else works." }
Ok ("claude=" + ((claude --version 2>$null) -split "`n")[0] + " · node=" + (node -v) + " · npm=" + (npm -v))

# ===== 1) agent-skills plugin (idempotent) =====
Say "Installing the agent-skills plugin"
$pluginList = & claude plugin list 2>$null
if ($pluginList -match 'agent-skills@addy-agent-skills') {
  Ok "plugin already installed"
} else {
  Run "claude plugin marketplace add addyosmani/agent-skills"
  Run "claude plugin install agent-skills@addy-agent-skills"
  Ok "agent-skills plugin installed"
}

# ===== 2) codebase-memory MCP =====
Say "Installing codebase-memory-mcp (binary)"
if (Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue) {
  Ok ("binary already present at " + (Get-Command codebase-memory-mcp).Source)
} else {
  Run "npm install -g codebase-memory-mcp"
}
Say "Registering the codebase-memory MCP server"
$mcpList = & claude mcp list 2>$null
if ($mcpList -match '^codebase-memory:') {
  Ok "MCP server already registered"
} else {
  Run "claude mcp add codebase-memory -- codebase-memory-mcp"
}

# ===== 3) (optional) Obsidian =====
if ($WithObsidian) {
  Say "Configuring the Obsidian MCP server on vault: $WithObsidian"
  if (-not (Test-Path $WithObsidian)) { Warn "creating the path (empty vault)"; Run "New-Item -ItemType Directory -Force '$WithObsidian' | Out-Null" }
  $cfgDir = Join-Path $WithObsidian ".obsidian"
  if (-not (Test-Path $cfgDir)) {
    Run "New-Item -ItemType Directory -Force '$cfgDir' | Out-Null"
    foreach ($j in 'app','appearance','hotkeys','core-plugins') { Run "Set-Content '$cfgDir\$j.json' '{}'" }
    Run "Set-Content '$cfgDir\community-plugins.json' '[]'"
  }
  $mcpList2 = & claude mcp list 2>$null
  if ($mcpList2 -notmatch '^obsidian:') {
    Run "claude mcp add obsidian -- npx -y obsidian-mcp '$WithObsidian'"
  }
  Ok "Obsidian MCP active on vault $WithObsidian"
} else {
  Warn "Obsidian not configured (re-run with -WithObsidian '<path>' if you want it)"
}

# ===== 4) settings.json (native PowerShell merge, no jq) =====
Say "Updating ~/.claude/settings.json (opusplan model + read-only allowlist, non-destructive merge)"
$settingsPath = Join-Path $HOME ".claude\settings.json"
if (-not (Test-Path (Split-Path $settingsPath))) { New-Item -ItemType Directory -Force (Split-Path $settingsPath) | Out-Null }
if (-not (Test-Path $settingsPath)) { '{}' | Set-Content $settingsPath -Encoding UTF8 }
$allow = @(
  "mcp__codebase-memory__search_graph","mcp__codebase-memory__trace_path",
  "mcp__codebase-memory__get_code_snippet","mcp__codebase-memory__get_graph_schema",
  "mcp__codebase-memory__get_architecture","mcp__codebase-memory__search_code",
  "mcp__codebase-memory__list_projects","mcp__codebase-memory__index_status",
  "mcp__obsidian__search-vault","mcp__obsidian__read-note","mcp__obsidian__list-available-vaults",
  "Bash(claude mcp list)"
)
if ($DryRun) {
  Write-Host "[dry-run] merge settings.json (model=opusplan, permissions.allow ⊕ read-only allowlist)"
} else {
  $obj = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
  if (-not $obj.ContainsKey('model'))       { $obj['model'] = 'opusplan' }
  if (-not $obj.ContainsKey('permissions')) { $obj['permissions'] = @{} }
  if (-not $obj['permissions'].ContainsKey('allow')) { $obj['permissions']['allow'] = @() }
  $merged = ($obj['permissions']['allow'] + $allow) | Sort-Object -Unique
  $obj['permissions']['allow'] = @($merged)
  $obj | ConvertTo-Json -Depth 8 | Set-Content $settingsPath -Encoding UTF8
}
Ok "settings.json updated"

# ===== 5) CLAUDE.md (marked block, safe to re-run) =====
Say "Updating ~/.claude/CLAUDE.md"
$claudeMd = Join-Path $HOME ".claude\CLAUDE.md"
$markBegin = "<!-- ai-engineering-layer: begin -->"
$markEnd   = "<!-- ai-engineering-layer: end -->"
$block = @"
$markBegin
## Code: use the knowledge graph BEFORE grep/reading files
The ``codebase-memory`` MCP server is active. In indexed projects (``list_projects``) use the graph
tools FIRST (``search_graph``, ``search_code``, ``trace_path``, ``get_code_snippet``,
``get_architecture``); fall back to grep only when the project isn't in the graph or you need exact text.

## Knowledge in Obsidian (if configured)
MCP server ``obsidian`` (personal vault): ``search-vault``/``read-note`` for ADRs, decisions, conventions.

## Model selection (cost-based routing)
Default ``opusplan``. When delegating via Agent: ``haiku`` for search/lookup, ``sonnet`` for impl/tests,
``opus`` for architecture/deep analysis. Grunt work goes to cheaper models.
$markEnd
"@
if ($DryRun) {
  Write-Host "[dry-run] writing/updating marked block in $claudeMd"
} else {
  if ((Test-Path $claudeMd) -and (Get-Content $claudeMd -Raw) -match [regex]::Escape($markBegin)) {
    $content = Get-Content $claudeMd -Raw
    $pattern = [regex]::Escape($markBegin) + '[\s\S]*?' + [regex]::Escape($markEnd)
    $content = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.Regex]::Escape($block) -replace '\\','')
    Set-Content $claudeMd $content -Encoding UTF8
  } else {
    Add-Content $claudeMd ("`n" + $block) -Encoding UTF8
  }
}
Ok "CLAUDE.md updated"

# ===== 6) Clone framework template =====
Say "Cloning the framework template into $FrameworkDir"
if (Test-Path (Join-Path $FrameworkDir ".git")) {
  Ok "already present — updating"
  Run "git -C '$FrameworkDir' pull --ff-only"
} else {
  Run "git clone --depth 1 '$RepoUrl' '$FrameworkDir'"
}

# ===== 7) (optional) Re-indexing routine via Task Scheduler =====
if ($WithReindexRoutine) {
  Say "Installing the scheduled routine (Task Scheduler, 03:17)"
  $scriptsDir = Join-Path $HOME ".claude\scripts"
  $logsDir    = Join-Path $HOME ".claude\logs"
  New-Item -ItemType Directory -Force $scriptsDir | Out-Null
  New-Item -ItemType Directory -Force $logsDir    | Out-Null
  $reindex = Join-Path $scriptsDir "reindex_codebase_memory.ps1"
  Copy-Item (Join-Path $FrameworkDir "distribution\reindex_codebase_memory.ps1") $reindex -Force
  $taskName = "AENGL Reindex"
  # remove if it exists (idempotent)
  schtasks /Query /TN $taskName 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { Run "schtasks /Delete /TN '$taskName' /F" }
  Run "schtasks /Create /SC DAILY /ST 03:17 /TN '$taskName' /TR 'powershell -NoProfile -ExecutionPolicy Bypass -File `"$reindex`"' /RL LIMITED"
  Ok "scheduled routine installed"
} else {
  Warn "Re-indexing routine not installed (re-run with -WithReindexRoutine if you want it)"
}

# ===== 8) Summary =====
Write-Host ""
Write-Host "================================================================" -ForegroundColor White
Write-Host "Setup complete. What you have now (restart Claude Code to load the plugin):" -ForegroundColor Green
Write-Host "  • /spec /plan /build /test /review /ship  (agent-skills, 28 skills)"
Write-Host "  • MCP codebase-memory   →   list_projects · search_graph · trace_path · get_architecture · ..."
if ($WithObsidian)        { Write-Host "  • MCP obsidian        →   search-vault · read-note" }
Write-Host "  • Default model: opusplan (Opus for planning, Sonnet for execution)"
Write-Host "  • Graph-first rule in ~/.claude/CLAUDE.md"
Write-Host "  • Framework template:    $FrameworkDir"
if ($WithReindexRoutine)  { Write-Host "  • Scheduled routine (Task Scheduler): AENGL Reindex, 03:17" }
if (-not $bashAvailable)  { Write-Host "  ! WARNING: without 'bash' on PATH (Git Bash or WSL), Claude Code hooks will not run." -ForegroundColor Yellow }
Write-Host ""
Write-Host "To enable the 3 enforcement rings on ONE target repo (requires Git Bash/WSL):" -ForegroundColor White
Write-Host "  cd <repo>"
Write-Host "  Copy-Item `"$FrameworkDir\.github\PULL_REQUEST_TEMPLATE.md`" .github\ -Force"
Write-Host "  Copy-Item `"$FrameworkDir\.github\workflows\non-negotiables.yml`" .github\workflows\ -Force"
Write-Host "  Copy-Item -Recurse `"$FrameworkDir\enforcement`" .\ -Force"
Write-Host "  Copy-Item `"$FrameworkDir\enforcement\.pre-commit-config.yaml`" .pre-commit-config.yaml -Force"
Write-Host "  pre-commit install"
Write-Host ""
Write-Host "Uninstall: claude plugin uninstall agent-skills · claude mcp remove codebase-memory"
Write-Host "================================================================" -ForegroundColor White
