<#
Re-indicizza tutti i progetti presenti nel knowledge graph di codebase-memory-mcp.
Equivalente Windows del reindex bash; usa la CLI nativa del binario, niente bash necessario.
Pensato per il Task Scheduler (schedulato dall'installer ps1).
#>
$ErrorActionPreference = 'Continue'
$bin = (Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue).Source
$logDir = Join-Path $HOME ".claude\logs"
$log = Join-Path $logDir "codebase-memory-reindex.log"
New-Item -ItemType Directory -Force $logDir | Out-Null

"===== reindex $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Add-Content $log

if (-not $bin) {
  "[error] binario non trovato — installalo con: npm i -g codebase-memory-mcp" | Add-Content $log
  exit 1
}

# Estrai i progetti
$raw = & $bin cli list_projects 2>$null
$jsonLine = ($raw | Select-String '^{' | Select-Object -First 1).Line
if (-not $jsonLine) { "[warn] nessun output JSON da list_projects" | Add-Content $log; exit 0 }
$projects = ($jsonLine | ConvertFrom-Json).projects

foreach ($p in $projects) {
  $root = $p.root_path
  if (Test-Path $root) {
    "[reindex] $root" | Add-Content $log
    $payload = (@{ repo_path = $root; mode = "full" } | ConvertTo-Json -Compress)
    & $bin cli index_repository $payload 2>&1 | Add-Content $log
    "" | Add-Content $log
  } else {
    "[skip-missing] $root" | Add-Content $log
  }
}

"done $(Get-Date -Format 'HH:mm:ss')" | Add-Content $log
