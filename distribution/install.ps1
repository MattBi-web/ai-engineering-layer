<#
AI Engineering Layer — installer per Windows (PowerShell 5.1+ / 7+).

Uso one-liner (modalità base, senza argomenti):
  irm https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.ps1 | iex

Con argomenti (Obsidian / routine in Task Scheduler):
  irm <URL>/install.ps1 -OutFile install.ps1
  .\install.ps1 -WithObsidian "$HOME\Documents\Memoria_AI" -WithReindexRoutine

Idempotente. Non sovrascrive le tue impostazioni esistenti — fa merge dove serve.
Per i Claude Code hook (block-destructive-bash, ecc.) serve `bash` (Git Bash o WSL): se non c'è,
l'install resta valido ma gli hook saranno disabilitati (lo segnaliamo).
#>

[CmdletBinding()]
param(
  [string]$RepoUrl       = "https://github.com/MattBi-web/ai-engineering-layer.git",   # ← cambia OWNER prima di pubblicare
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
  - plugin agent-skills (/spec /plan /build /test /review /ship + 28 skill)
  - MCP codebase-memory (knowledge graph del codice)
  - regola graph-first + model routing (opusplan)
  - template del framework (governance + enforcement + 12 layer)
  - opzionale: Obsidian, routine schedulata (Task Scheduler)
================================================================
"@ -ForegroundColor White

# ===== Prereq =====
Say "Verifico prerequisiti"
foreach ($cmd in @('claude','node','npm','git')) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Fail "manca: $cmd — installalo e riprova" }
}
$bashAvailable = [bool](Get-Command bash -ErrorAction SilentlyContinue)
if (-not $bashAvailable) { Warn "bash non trovato: i Claude Code hook (PreToolUse/Stop/...) richiedono Git Bash o WSL. Tutto il resto funziona." }
Ok ("claude=" + ((claude --version 2>$null) -split "`n")[0] + " · node=" + (node -v) + " · npm=" + (npm -v))

# ===== 1) Plugin agent-skills (idempotente) =====
Say "Installo il plugin agent-skills"
$pluginList = & claude plugin list 2>$null
if ($pluginList -match 'agent-skills@addy-agent-skills') {
  Ok "plugin già installato"
} else {
  Run "claude plugin marketplace add addyosmani/agent-skills"
  Run "claude plugin install agent-skills@addy-agent-skills"
  Ok "plugin agent-skills installato"
}

# ===== 2) codebase-memory MCP =====
Say "Installo codebase-memory-mcp (binario)"
if (Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue) {
  Ok ("binario già presente in " + (Get-Command codebase-memory-mcp).Source)
} else {
  Run "npm install -g codebase-memory-mcp"
}
Say "Registro il server MCP codebase-memory"
$mcpList = & claude mcp list 2>$null
if ($mcpList -match '^codebase-memory:') {
  Ok "server MCP già registrato"
} else {
  Run "claude mcp add codebase-memory -- codebase-memory-mcp"
}

# ===== 3) (opzionale) Obsidian =====
if ($WithObsidian) {
  Say "Configuro server MCP Obsidian sul vault: $WithObsidian"
  if (-not (Test-Path $WithObsidian)) { Warn "creo il path (vault vuoto)"; Run "New-Item -ItemType Directory -Force '$WithObsidian' | Out-Null" }
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
  Ok "Obsidian MCP attivo sul vault $WithObsidian"
} else {
  Warn "Obsidian non configurato (riavvia con -WithObsidian '<path>' se lo vuoi)"
}

# ===== 4) settings.json (merge nativo PowerShell, senza jq) =====
Say "Aggiorno ~/.claude/settings.json (model opusplan + allowlist read-only, merge non distruttivo)"
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
  Write-Host "[dry-run] merge settings.json (model=opusplan, permissions.allow ⊕ allowlist read-only)"
} else {
  $obj = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
  if (-not $obj.ContainsKey('model'))       { $obj['model'] = 'opusplan' }
  if (-not $obj.ContainsKey('permissions')) { $obj['permissions'] = @{} }
  if (-not $obj['permissions'].ContainsKey('allow')) { $obj['permissions']['allow'] = @() }
  $merged = ($obj['permissions']['allow'] + $allow) | Sort-Object -Unique
  $obj['permissions']['allow'] = @($merged)
  $obj | ConvertTo-Json -Depth 8 | Set-Content $settingsPath -Encoding UTF8
}
Ok "settings.json aggiornato"

# ===== 5) CLAUDE.md (blocco marcato, ri-eseguibile) =====
Say "Aggiorno ~/.claude/CLAUDE.md"
$claudeMd = Join-Path $HOME ".claude\CLAUDE.md"
$markBegin = "<!-- ai-engineering-layer: begin -->"
$markEnd   = "<!-- ai-engineering-layer: end -->"
$block = @"
$markBegin
## Codice: usa il knowledge graph PRIMA di grep/lettura file
È attivo il server MCP ``codebase-memory``. Nei progetti indicizzati (``list_projects``) usa PRIMA gli
strumenti del grafo (``search_graph``, ``search_code``, ``trace_path``, ``get_code_snippet``,
``get_architecture``); fallback a grep solo quando il progetto non è nel grafo o serve testo esatto.

## Conoscenza in Obsidian (se configurato)
Server MCP ``obsidian`` (vault personale): ``search-vault``/``read-note`` per ADR, decisioni, convenzioni.

## Selezione del modello (routing per costo)
Default ``opusplan``. Delegando via Agent: ``haiku`` per ricerche/lookup, ``sonnet`` per impl/test,
``opus`` per architettura/analisi profonda. La manovalanza va su modelli economici.
$markEnd
"@
if ($DryRun) {
  Write-Host "[dry-run] scrivo/aggiorno blocco marcato in $claudeMd"
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
Ok "CLAUDE.md aggiornato"

# ===== 6) Clone framework template =====
Say "Clono il template framework in $FrameworkDir"
if (Test-Path (Join-Path $FrameworkDir ".git")) {
  Ok "già presente — aggiorno"
  Run "git -C '$FrameworkDir' pull --ff-only"
} else {
  Run "git clone --depth 1 '$RepoUrl' '$FrameworkDir'"
}

# ===== 7) (opzionale) Routine re-indexing via Task Scheduler =====
if ($WithReindexRoutine) {
  Say "Installo la routine schedulata (Task Scheduler, 03:17)"
  $scriptsDir = Join-Path $HOME ".claude\scripts"
  $logsDir    = Join-Path $HOME ".claude\logs"
  New-Item -ItemType Directory -Force $scriptsDir | Out-Null
  New-Item -ItemType Directory -Force $logsDir    | Out-Null
  $reindex = Join-Path $scriptsDir "reindex_codebase_memory.ps1"
  Copy-Item (Join-Path $FrameworkDir "distribution\reindex_codebase_memory.ps1") $reindex -Force
  $taskName = "AENGL Reindex"
  # rimuovi se esiste (idempotente)
  schtasks /Query /TN $taskName 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { Run "schtasks /Delete /TN '$taskName' /F" }
  Run "schtasks /Create /SC DAILY /ST 03:17 /TN '$taskName' /TR 'powershell -NoProfile -ExecutionPolicy Bypass -File `"$reindex`"' /RL LIMITED"
  Ok "routine schedulata installata"
} else {
  Warn "Routine re-indexing non installata (riavvia con -WithReindexRoutine se la vuoi)"
}

# ===== 8) Riepilogo =====
Write-Host ""
Write-Host "================================================================" -ForegroundColor White
Write-Host "Setup completato. Cosa hai ora (riavvia Claude Code per caricare il plugin):" -ForegroundColor Green
Write-Host "  • /spec /plan /build /test /review /ship  (agent-skills, 28 skill)"
Write-Host "  • MCP codebase-memory   →   list_projects · search_graph · trace_path · get_architecture · ..."
if ($WithObsidian)        { Write-Host "  • MCP obsidian        →   search-vault · read-note" }
Write-Host "  • Modello default: opusplan (Opus in plan, Sonnet in esecuzione)"
Write-Host "  • Regola graph-first in ~/.claude/CLAUDE.md"
Write-Host "  • Framework template:    $FrameworkDir"
if ($WithReindexRoutine)  { Write-Host "  • Routine schedulata (Task Scheduler): AENGL Reindex, 03:17" }
if (-not $bashAvailable)  { Write-Host "  ! ATTENZIONE: senza 'bash' in PATH (Git Bash o WSL), i Claude Code hook non gireranno." -ForegroundColor Yellow }
Write-Host ""
Write-Host "Per attivare i 3 cordoni di enforcement su UN repo target (richiede Git Bash/WSL):" -ForegroundColor White
Write-Host "  cd <repo>"
Write-Host "  Copy-Item `"$FrameworkDir\.github\PULL_REQUEST_TEMPLATE.md`" .github\ -Force"
Write-Host "  Copy-Item `"$FrameworkDir\.github\workflows\non-negotiables.yml`" .github\workflows\ -Force"
Write-Host "  Copy-Item -Recurse `"$FrameworkDir\enforcement`" .\ -Force"
Write-Host "  Copy-Item `"$FrameworkDir\enforcement\.pre-commit-config.yaml`" .pre-commit-config.yaml -Force"
Write-Host "  pre-commit install"
Write-Host ""
Write-Host "Disinstall: claude plugin uninstall agent-skills · claude mcp remove codebase-memory"
Write-Host "================================================================" -ForegroundColor White
