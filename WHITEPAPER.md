# AI Engineering Layer
*Un framework operativo per scrivere software con assistenti AI senza moltiplicare il debito tecnico, i token e il rischio di sicurezza.*

> v1 · 2026 — M. Bigi

## Abstract
Gli agenti di coding (Claude Code, Cursor, Codex…) hanno cambiato la velocità di sviluppo, ma hanno
introdotto tre debiti silenziosi: **token sprecati** (l'agente legge file alla cieca), **codice duplicato**
(non sa cosa esiste già), e **vulnerabilità sistematiche** (per Veracode, *il 45% del codice AI-generato
introduce OWASP Top-10* — RLS scordate, rate limit assenti, secrets hardcoded). L'**AI Engineering Layer**
è una composizione di tre strati — *retrieval+memoria, processo, enforcement* — che indurisce il loop di
sviluppo *senza* obbligare a nuovi tool: si poggia su Claude Code e su un plugin community ben mantenuto
([`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills)) e aggiunge solo il **delta**
che nessuno standard copre: un *bootstrap di contesto* su knowledge-graph del codice, e tre **guardrail
deterministici** (`pre-commit + hooks + CI`) che rifiutano merge senza RLS, senza rate-limit e con secrets
in chiaro.

## Perché esiste
1. **Token economics.** Un agente che esplora a grep legge migliaia di righe per rispondere a una domanda
   strutturale. Un grafo di codice ([`codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp)
   misura ~99% di token in meno su query strutturali) risponde in pochi nodi. È il singolo intervento con
   il miglior rapporto valore/sforzo per chi usa LLM ogni giorno.
2. **Anti-vibe-coding.** L'agente, se non glielo si impedisce, scrive prosa di codice "che sembra giusta".
   Le best-practice 2026 (Spec-Driven Development, Plan-Mode, Review separata, OWASP LLM/Agents) convergono
   sullo stesso schema: *prima decidi, poi tipi, poi testi, poi implementi, poi un altro rivede*. Forzare
   quello schema riduce il debito.
3. **Sicurezza AI-specifica.** *Package hallucination* (l'agente inventa nomi di librerie che attaccanti
   registrano), secrets committati, RLS dimenticata su Supabase: sono pattern *sistematici*, non incidenti
   isolati. Un layer che li intercetta in CI prima del merge li elimina alla radice.

## La tesi in una frase
*Standard di processo (agent-skills) **+** retrieval/memoria (knowledge-graph + Obsidian) **+** enforcement
deterministico (pre-commit, hook, CI) = un agente che produce codice production-ready, non solo plausibile.*

## Architettura — i 3 cerchi
| Cerchio | Cosa fa | Quando si attiva |
|---|---|---|
| **1. Infra (retrieval + memoria)** | MCP `codebase-memory` (graph del codice, Cypher), MCP `obsidian` (memoria a lungo termine), model routing `opusplan`, regola *graph-first* in `CLAUDE.md` | **Sempre**. Dimenticatelo, lavora in background. |
| **2. Processo** | `agent-skills` di Addy Osmani: 28 skill + `/spec /plan /build /test /review /ship`, review in fan-out parallelo (code-reviewer + security-auditor + test-engineer) | **Quando lavori su codice** (non in chat generiche). |
| **3. Enforcement** | 3 cordoni: **pre-commit** (gitleaks + script custom) → **hook Claude Code** (blocco bash distruttivo, stop su test rossi) → **CI** (`non-negotiables.yml` + `ai-code-gate.yml` stratificato per layer) | **Per repo target** in cui si committa codice prodotto. |

## Le 3 Non-Negotiables
Sono i fallimenti più comuni e più costosi del codice AI-generato (Lovable e simili). Il framework li
rifiuta a livello CI:
1. **RLS / authz su ogni tabella non pubblica** — anche se l'agente la dimentica, la migration non viene
   accettata (verifica SQL nativa; per repo Supabase-client si richiede un'**attestazione tracciata**).
2. **Rate limit su ogni endpoint pubblico** — middleware globale *oppure* per-route, contati. La
   "menzione di limiter" non basta.
3. **Secrets solo da vault/KMS, mai committati** — gitleaks profondo + check su `.env` tracciati.

## I 12 Production Layer (l'iceberg)
La punta è il codice; il 90% del lavoro di produzione sta sotto. Ogni PR dichiara quali layer tocca e il
rigore scala col rischio (`cosmetic` / `standard` / `critical`). I 12 layer sono caricati **on-demand**
via una *Claude Code Skill* (progressive disclosure) per non gonfiare il contesto: L0 governance, L1
architettura, L2 contratti/API, L3 data, L4 auth, L5 security/secrets, L6 reliability, L7 performance,
L8 observability, L9 deployment, L10 operations, L11 compliance.

## Token economics — perché si risparmia (e dove)
1. **Retrieval strutturato.** Sostituire grep e letture cieche con `search_graph`/`trace_path`/`get_architecture`
   significa portare in contesto *nodi rilevanti*, non file interi. Su query strutturali (callers, route,
   moduli) il guadagno dichiarato dal vendor è ~99%; sul campo il valore tipico è **una percentuale a due
   cifre alta** purché il progetto sia indicizzato.
2. **Progressive disclosure delle regole.** Le 12 schede-layer si caricano solo per il layer toccato: una
   UI tweak non porta in contesto le 170 righe di observability/compliance.
3. **Model routing.** Default `opusplan` (Opus pianifica, Sonnet esegue). Sub-agent: `haiku` per i lookup
   nel grafo / Obsidian, `sonnet` per impl/test, `opus` solo per architettura/review. La manovalanza non
   gira su Opus.
4. **Re-indicizzazione incrementale.** Solo i file cambiati rientrano nel grafo. Una routine notturna
   mantiene fresco l'indice senza intervento.

## Cosa NON è
- *Non* è un proxy verso altri provider. Stai sempre su Anthropic; nessun dato esfiltrato. Compatibile con
  Claude Code Enterprise.
- *Non* è un'app standalone. È un *layer* sopra Claude Code: il valore è nel comportamento dell'agente,
  non in una UI separata.
- *Non* sostituisce la code review umana per i path critici (auth/payment/PII richiedono ≥2 review).
- *Non* impone un nuovo workflow: il processo è quello di `agent-skills`, già adottato da decine di team.

## Casi d'uso (decision rule)
| Scenario | Cosa fai |
|---|---|
| Chat di domande/ricerca/idee | Nulla. Il Cerchio 1 lavora da solo. |
| Lavoro su un repo già indicizzato | Lascia che la regola graph-first guidi (`search_graph` invece di grep). |
| Sviluppo di una feature / refactor serio | `/spec → /plan → /build → /test → /review → /ship`. |
| Sviluppo su repo critico (auth, payment, PII, codice cliente) | Aggiungi anche il **Cerchio 3** dentro il repo: `pre-commit install` + workflow CI + PR template. |

## Limiti onesti
- Gli script di enforcement sono **euristici** (grep/regex): vanno tarati sul vero stack. Il pilota su
  un repo reale è il modo serio di shippare il framework su una codebase.
- Il graph-first vale per **progetti indicizzati**. Per cartelle non indicizzate, grep ed editor classici
  restano la strada.
- Il riconoscimento della RLS via codice copre i repo con migration SQL; per repo Supabase-client la RLS
  è esterna → richiediamo un'**attestazione tracciata** in `governance/`.
- "*-99% token*" è una claim del vendor del graph: nei casi reali il guadagno è grande ma variabile.

## Setup (1 riga)
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.sh | bash
```
Vedi [`distribution/INSTALL.md`](distribution/INSTALL.md) per flag, opt-in e troubleshooting.
**Utenti Windows:** [`distribution/INSTALL.windows.md`](distribution/INSTALL.windows.md) — due strade,
WSL2 (consigliata, comando identico a Mac/Linux) o nativo via `install.ps1`. La CI server-side gira
comunque su Ubuntu, quindi i guardrail "duri" pre-merge non dipendono dal SO dello sviluppatore.

## Riferimenti
- Addy Osmani — *Agent Skills (Production-Grade Engineering Skills for AI Coding Agents)*, MIT.
- *codebase-memory-mcp* (DeusData) — Tree-Sitter Knowledge Graphs for LLM Code Exploration via MCP.
- OWASP LLM Top 10 (2025-2026) / OWASP Top 10 for Agents.
- Veracode 2026 — *45% of AI-generated code samples introduce OWASP Top 10 vulnerabilities*.
- Anthropic — *Claude Code: hooks, sub-agents, agent skills, model selection*.
- Google SRE — *Four Golden Signals*, *SLOs & Error Budgets*.

## Stato e roadmap
- **v1** (2026): infra, processo, enforcement, 12 layer, governance, audit mensile, installer.
- **prossimi**: rifinitura degli euristici per stack diversi, ADR/runbook auto-generati da `/ship`, bundle
  come plugin Claude Code unico, dashboard di gap-tracking del framework.
