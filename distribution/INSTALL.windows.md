# AI Engineering Layer — Installation on **Windows**

Windows-specific version of the installation guide. Same product, two paths.

## 🎯 Which path to choose

| | **Option A — WSL2 (Ubuntu)** *recommended* | **Option B — Native Windows** |
|---|---|---|
| Setup | one-off: install WSL2 Ubuntu | none, you're ready |
| Parity with Mac/Linux users | ✅ identical | partial |
| `install.sh` (single script) | ✅ works as-is | ⚠️ needs the `.ps1` version |
| Claude Code hooks (`block-destructive-bash`, etc.) | ✅ | ⚠️ disabled without Git Bash/WSL |
| Target repo `pre-commit` hooks | ✅ | ⚠️ need `bash`/`sh` (Git Bash is enough) |
| Nightly re-indexing routine | ✅ via `cron`/launchd equivalent | ✅ via **Task Scheduler** (shipped as `.ps1`) |

**Rule of thumb:** unless you have specific constraints, **go with WSL2**. If you must stay on native Windows (e.g. managed-device policies), it works, but install **Git Bash** or **WSL** for the repo's local hooks. Server-side CI (GitHub Actions) runs on Ubuntu regardless, so the "hard" pre-merge guardrails stay active either way.

---

## Option A — WSL2 (Ubuntu) — *recommended*

### 1. Install WSL2 (once)
In PowerShell (as Administrator):
```powershell
wsl --install -d Ubuntu
```
Reboot, complete the Ubuntu user setup, then enter the shell:
```powershell
wsl
```

### 2. Prerequisites inside Ubuntu
```bash
sudo apt update && sudo apt install -y nodejs npm git jq
# claude code: follow https://docs.anthropic.com for the native Linux install
```

### 3. One-liner (same as Mac/Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.sh | bash
```
From here on, follow the main guide [`INSTALL.md`](INSTALL.md).

---

## Option B — Native Windows (PowerShell)

### Prerequisites
- **PowerShell 5.1+** (preinstalled on Windows 10/11) or **PowerShell 7**.
- **Node.js 18+** ([official installer](https://nodejs.org)).
- **Git for Windows** (also ships Git Bash — useful for hooks).
- **Claude Code** for Windows.
- (Optional but recommended) **WSL** or **Git Bash** for the repo's local hooks.

### One-liner (no options)
```powershell
irm https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.ps1 | iex
```

### With options (Obsidian and/or nightly routine)
When you need arguments, download first, then run:
```powershell
irm https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.ps1 -OutFile install.ps1
.\install.ps1 -WithObsidian "$HOME\Documents\Memoria_AI" -WithReindexRoutine
```

### Available flags
| Flag | Effect |
|---|---|
| `-WithObsidian <path>` | Registers the Obsidian MCP server on the given vault (creates the `.obsidian/` config if missing) |
| `-WithReindexRoutine` | Creates a **Task Scheduler** task (`AENGL Reindex`, daily at 03:17) that re-indexes projects via `codebase-memory-mcp cli` |
| `-FrameworkDir <path>` | Folder to clone the template into (default: `%USERPROFILE%\Dev\ai-engineering-layer`) |
| `-DryRun` | Shows what it would do without changing anything |
| `-Help` | Prints the header with usage/examples |

### Execution policy
If you get an execution policy error:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```
(applies to the current session only).

### Uninstall
```powershell
claude plugin uninstall agent-skills
claude mcp remove codebase-memory
claude mcp remove obsidian        # if installed
schtasks /Delete /TN "AENGL Reindex" /F   # if you installed the routine
# the other keys in $HOME\.claude\settings.json and CLAUDE.md stay untouched
```

---

## Native Windows: what changes in practice

1. **The enforcement bash scripts** (`enforcement/scripts/*.sh`) require **bash**. Options:
   - Install Git for Windows (includes Git Bash) → `pre-commit` runs them through `sh` correctly.
   - Or use WSL just for committing inside the target repo.
2. **The Claude Code hook `block-destructive-bash`** (and the others) is bash → it won't run without bash on PATH. The installer warns you about this.
3. **The re-indexing routine** on native Windows goes through Task Scheduler + the `reindex_codebase_memory.ps1` script (no bash dependency; it calls the `codebase-memory-mcp` binary's CLI directly).
4. **Everything else** (`/spec`, `/plan`, `/ship`, the MCP servers, graph-first, model routing) is identical across Win/Mac/Linux.

## Server-side: the "hard" guardrails are OS-independent
GitHub Actions CI (`non-negotiables.yml`, `ai-code-gate.yml`) runs on `ubuntu-latest`. So even if you bypass pre-commit with `--no-verify` (not recommended), the merge stays blocked server-side if the RLS / rate-limit / secrets checks fail.
