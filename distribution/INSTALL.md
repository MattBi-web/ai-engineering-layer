# AI Engineering Layer — Installazione

Setup completo di un ambiente Claude Code "anti vibe-coding" + retrieval intelligente. Una sola riga.

## In una riga
**Repo pubblico** (il curl funziona così com'è):
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.sh | bash
```
**Repo privato** (il curl richiede auth → usa `gh repo clone`, una riga ugualmente):
```bash
gh repo clone MattBi-web/ai-engineering-layer ~/Dev/ai-engineering-layer && bash ~/Dev/ai-engineering-layer/distribution/install.sh
```

Opzioni più complete (Obsidian + routine notturna):
```bash
curl -fsSL <URL>/install.sh | bash -s -- --with-obsidian "$HOME/Documents/Memoria_AI" --with-reindex-routine
```

> Lo script è **idempotente** (re-eseguibile in sicurezza), fa **dry-run** con `--dry-run`, e
> **non sovrascrive** le tue impostazioni esistenti — fa solo merge dove serve.

## Cosa installa
| Componente | Sempre | Opt-in |
|---|---|---|
| Plugin Claude Code `agent-skills` (28 skill + `/spec /plan /build /test /review /ship`) | ✅ | |
| MCP `codebase-memory` (knowledge graph del codice, ricerche -99% token) | ✅ | |
| Modello default `opusplan` + permessi read-only allowlist | ✅ | |
| Regola "graph-first" + routing dei subagent in `~/.claude/CLAUDE.md` | ✅ | |
| Template del framework in `~/Dev/ai-engineering-layer` (governance, enforcement, 12 layer) | ✅ | |
| MCP `obsidian` su un vault personale | | `--with-obsidian <path>` |
| Routine launchd notturna che ri-indicizza i progetti (solo macOS) | | `--with-reindex-routine` |

## Per utenti Windows
Guida dedicata: [`INSTALL.windows.md`](INSTALL.windows.md). Due strade: **WSL2 Ubuntu** (consigliata: stesso comando di Mac/Linux) o **Windows nativo** con l'installer PowerShell `install.ps1` (one-liner equivalente).

## Prerequisiti
- **Claude Code** installato (`claude` su `PATH`).
- **Node 18+** (per `npm`, `npx`).
- **git**, **jq**, **bash**.
- macOS o Linux nativi. Windows → vedi [`INSTALL.windows.md`](INSTALL.windows.md).

## Dopo l'installazione
1. **Riavvia Claude Code** (`/exit` poi rilancia) per caricare il plugin e le nuove impostazioni.
2. In una sessione vedi i nuovi comandi: `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`, `/code-simplify`.
3. **Indicizza un tuo progetto** (la prima volta, in Claude Code):
   *"Index this project"* — Claude chiamerà automaticamente il tool `index_repository`.
   Da quel momento, per esplorare il codice userà `search_graph` / `trace_path` / `get_architecture`
   invece di grep — meno token, niente allucinazioni.

## Quando usi cosa
- **Chat di ricerca, domande, idee** → niente da fare: opusplan + memoria + MCP girano in background.
- **Lavoro su un progetto indicizzato** → il graph-first si attiva da solo.
- **Sviluppi una feature / refactor serio** → usa il ciclo `/spec → /ship` di agent-skills.
- **Repo importante (auth, payment, PII, codice cliente prod)** → droppa il **framework template** in quel repo (3 cordoni di enforcement che bloccano i merge insicuri).

## Attivare i guardrail "duri" su un repo target
```bash
FW="$HOME/Dev/ai-engineering-layer"
cd <repo>
cp "$FW/.github/PULL_REQUEST_TEMPLATE.md" .github/
cp "$FW/.github/workflows/non-negotiables.yml" .github/workflows/
cp -r "$FW/enforcement" ./
cp "$FW/enforcement/.pre-commit-config.yaml" .pre-commit-config.yaml
pre-commit install
```
Da quel momento ogni commit/PR è gattato sulle 3 Non-Negotiables: **RLS** (ogni tabella), **rate-limit**
(ogni endpoint pubblico), **secrets** (mai committati).

## Troubleshooting
- *"jq required"*: `brew install jq` (macOS) o `apt-get install jq` (Linux).
- *plugin non visibile*: hai riavviato Claude Code? Controlla con `claude plugin list`.
- *MCP non risponde*: `claude mcp list` → entrambi devono essere `✓ Connected`.
- *vault Obsidian rifiutato*: il server richiede una config `.obsidian/`. L'installer la crea minimale se manca.

## Disinstallazione
```bash
claude plugin uninstall agent-skills
claude mcp remove codebase-memory
claude mcp remove obsidian        # se installato
# (opzionale) launchctl unload "$HOME/Library/LaunchAgents/com.aengl.reindex.plist"
# le tue altre chiavi in ~/.claude/settings.json e ~/.claude/CLAUDE.md restano intatte
```

## Sicurezza & privacy
- Tutto locale. Nessun dato esce dalla tua macchina (a parte le normali chiamate API Anthropic che già fai con Claude Code).
- Il plugin `agent-skills` è MIT, 46k ⭐, ispezionato — l'unica rete attiva è una cache locale di WebFetch (revalidazione ETag della stessa URL che stai già fetchando).
- Il binario `codebase-memory-mcp` è single-binary statico locale.
