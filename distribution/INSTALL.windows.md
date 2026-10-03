# AI Engineering Layer — Installazione su **Windows**

Versione ad hoc della guida d'installazione per utenti Windows. Stesso prodotto, due strade.

## 🎯 Quale strada scegliere

| | **Opzione A — WSL2 (Ubuntu)** *consigliata* | **Opzione B — Windows nativo** |
|---|---|---|
| Setup | una tantum: installi WSL2 Ubuntu | nessuno, sei già pronto |
| Coerenza con i colleghi Mac/Linux | ✅ identica | parziale |
| `install.sh` (uno script unico) | ✅ funziona così com'è | ⚠️ serve la versione `.ps1` |
| Claude Code hook (`block-destructive-bash`, ecc.) | ✅ | ⚠️ disabilitati senza Git Bash/WSL |
| `pre-commit` hooks del repo target | ✅ | ⚠️ servono `bash`/`sh` (Git Bash basta) |
| Routine notturna di re-indexing | ✅ con `cron`/launchd-equivalente | ✅ via **Task Scheduler** (incluso come `.ps1`) |

**Regola pratica:** se non hai vincoli particolari, **vai di WSL2**. Se proprio devi restare Windows-nativo (es. policy aziendali), funziona, ma metti **Git Bash** o **WSL** per gli hook locali del repo. La CI server-side (GitHub Actions) gira su Ubuntu indipendentemente, quindi i guardrail "duri" pre-merge sono comunque attivi.

---

## Opzione A — WSL2 (Ubuntu) — *consigliata*

### 1. Installa WSL2 (una volta)
In PowerShell (come Amministratore):
```powershell
wsl --install -d Ubuntu
```
Riavvia, completa il setup utente Ubuntu, poi entra nella shell:
```powershell
wsl
```

### 2. Prerequisiti dentro Ubuntu
```bash
sudo apt update && sudo apt install -y nodejs npm git jq
# claude code: segui https://docs.anthropic.com per la procedura nativa Linux
```

### 3. One-liner (identico a Mac/Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.sh | bash
```
Da qui sei allineato con la guida principale [`INSTALL.md`](INSTALL.md).

---

## Opzione B — Windows nativo (PowerShell)

### Prerequisiti
- **PowerShell 5.1+** (preinstallato su Windows 10/11) o **PowerShell 7**.
- **Node.js 18+** ([installer ufficiale](https://nodejs.org)).
- **Git for Windows** (porta anche Git Bash — utile per gli hook).
- **Claude Code** per Windows.
- (Opzionale ma consigliato) **WSL** o **Git Bash** per gli hook locali del repo.

### One-liner (senza opzioni)
```powershell
irm https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.ps1 | iex
```

### Con opzioni (Obsidian e/o routine notturna)
Quando servono argomenti, scarica e poi esegui:
```powershell
irm https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.ps1 -OutFile install.ps1
.\install.ps1 -WithObsidian "$HOME\Documents\Memoria_AI" -WithReindexRoutine
```

### Flag disponibili
| Flag | Effetto |
|---|---|
| `-WithObsidian <path>` | Registra il server MCP Obsidian sul vault indicato (crea la config `.obsidian/` se manca) |
| `-WithReindexRoutine` | Crea un'attività in **Task Scheduler** (`AENGL Reindex`, ogni giorno 03:17) che ri-indicizza i progetti via `codebase-memory-mcp cli` |
| `-FrameworkDir <path>` | Cartella dove clonare il template (default: `%USERPROFILE%\Dev\ai-engineering-layer`) |
| `-DryRun` | Mostra cosa farebbe senza modificare nulla |
| `-Help` | Stampa l'header con uso/esempi |

### Esecuzione policy
Se ricevi un errore di execution policy:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```
(vale solo per la sessione corrente).

### Disinstallazione
```powershell
claude plugin uninstall agent-skills
claude mcp remove codebase-memory
claude mcp remove obsidian        # se installato
schtasks /Delete /TN "AENGL Reindex" /F   # se hai installato la routine
# le altre chiavi in $HOME\.claude\settings.json e CLAUDE.md restano intatte
```

---

## Quando usi Windows nativo: cosa cambia in pratica

1. **Gli script bash dell'enforcement** (`enforcement/scripts/*.sh`) richiedono **bash**. Soluzioni:
   - Installa Git for Windows (include Git Bash) → `pre-commit` li lancia via `sh` correttamente.
   - Oppure usa WSL anche solo per i commit dentro il repo target.
2. **Il Claude Code hook `block-destructive-bash`** (e gli altri) è bash → senza bash sul PATH non gira. L'installer te lo segnala con un warning.
3. **La routine di re-indexing** su Windows nativo passa per Task Scheduler + lo script `reindex_codebase_memory.ps1` (non dipende da bash, usa direttamente la CLI del binario `codebase-memory-mcp`).
4. **Tutto il resto** (`/spec`, `/plan`, `/ship`, le MCP, il graph-first, il routing modello) è identico tra Win/Mac/Linux.

## Server-side: i guardrail "duri" non dipendono dal SO
La CI GitHub Actions (`non-negotiables.yml`, `ai-code-gate.yml`) gira su `ubuntu-latest`. Quindi anche se aggiri pre-commit con `--no-verify` (sconsigliato), il merge resta bloccato lato server se RLS / rate-limit / secrets non passano.
