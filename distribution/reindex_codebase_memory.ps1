<#
Re-indexes every project in the codebase-memory-mcp knowledge graph.
Windows equivalent of the bash reindex script; uses the binary's native CLI, no bash required.
Meant for Task Scheduler (scheduled by the ps1 installer).
#>
$ErrorActionPreference = 'Continue'
$bin = (Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue).Source
$logDir = Join-Path $HOME ".claude\logs"
$log = Join-Path $logDir "codebase-memory-reindex.log"
New-Item -ItemType Directory -Force $logDir | Out-Null

"===== reindex $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Add-Content $log

if (-not $bin) {
  "[error] binary not found — install it with: npm i -g codebase-memory-mcp" | Add-Content $log
  exit 1
}

# Extract the projects
$raw = & $bin cli list_projects 2>$null
$jsonLine = ($raw | Select-String '^{' | Select-Object -First 1).Line
if (-not $jsonLine) { "[warn] no JSON output from list_projects" | Add-Content $log; exit 0 }
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
