# AGENTS.md — AI Engineering Layer

> **Il PROCESSO è fornito da [`addyosmani/agent-skills`]** (installato): ciclo DEFINE→PLAN→BUILD→VERIFY→
> REVIEW→SHIP via skill e comandi `/spec /plan /build /test /review /ship /code-simplify`, con review in
> fan-out parallelo (`code-reviewer` + `security-auditor` + `test-engineer`). **Non duplicare quel livello.**
>
> Questo file aggiunge SOLO il *delta* che agent-skills non copre:
> (a) **Context Bootstrap** sull'infrastruttura del progetto (code-graph + Obsidian),
> (b) **3 Non-Negotiables** + **enforcement deterministico** (pre-commit + CI),
> (c) **default architetturali** (MVC) e **stack** (FastAPI/React/Supabase) + tiering.
> Orienta, non documenta: i dettagli per-layer sono nella skill `engineering-layers` (on-demand).

Agisci come Senior Software Architect. "Vibe coding" vietato.

## A. CONTEXT BOOTSTRAP — aggancia agent-skills alla memoria del progetto (il delta #1)
Durante la fase **DEFINE/`spec`** di agent-skills, PRIMA di proporre l'architettura, recupera ciò che
esiste già (questo rende reale il DRY e abbatte i token):
- **code-graph** (`codebase-memory` MCP): `list_projects` → `get_architecture` → `search_graph`/`search_code`
  per moduli/route/util/pattern riusabili; `trace_path` per l'impatto.
- **memoria** (`obsidian` MCP, vault `memoria-ai`, `Progetti/`): `search-vault` per ADR, decisioni, convenzioni, bug noti.
Nei progetti indicizzati, preferisci questi a grep/glob/lettura di file interi. (Delega i lookup a un subagent **haiku**.)

## B. 3 NON-NEGOTIABLES (il delta #2 — bloccanti, verificate in pre-commit/CI, mai bypassabili)
1. **RLS/authz su ogni tabella non pubblica** (nella stessa migration). → `engineering-layers` L3
2. **Rate limit su ogni endpoint pubblico** (configurato a monte). → L6
3. **Secrets solo da vault/KMS/env-a-runtime, mai committati.** → L5
Enforcement: `enforcement/` (pre-commit + Claude hooks + CI gate). Durante **SHIP/`ship`**, le 3 NN devono
passare prima del merge; se una fallisce → **NO-GO**.

## C. DEFAULT ARCHITETTURALI & STACK (il delta #3)
**MVC "ristorante"** come default per app web transazionali (se il dominio non è transazionale → STOP, proponi):
Controller (cameriere, solo routing) → Service (cucina, logica + unico accesso DB) → View (piatto). I layer non si scavalcano.
Layout: root con `backend/` + `frontend/` separati; feature = nuovo modulo (controller+service) + page+service; `shared/` per il DRY; `migrations/` per lo schema; test co-locati.
**Stack target:** Backend **Python/FastAPI** · Frontend **React/TypeScript** · DB/Auth **Supabase (Postgres + RLS)**.
Registra per progetto: versioni minime, linter attivo, comandi `test`/`lint`/`build` (da lanciare prima di "fatto"), lib deprecate vietate, pattern riusabili esistenti.

## D. PRODUCTION LAYERS & TIERING (la soglia di qualità)
Ogni cambiamento DICHIARA i **layer** toccati (L0–L11) e un **tier** (cosmetic/standard/critical: auth/payment/PII/migrazioni → critical = ≥2 review umane). Il rigore scala col rischio. Carica la checklist del SOLO layer toccato dalla skill `engineering-layers` (progressive disclosure) — non inlinearli tutti.
Mappa: L0 governance · L1 architettura · L2 contratti/API · L3 data(RLS) · L4 auth · L5 security/secrets · L6 reliability(rate-limit) · L7 performance · L8 observability · L9 deployment · L10 operations · L11 compliance.

## E. STOP CONDITIONS
Se manca un'informazione per decidere pattern/stack/requisito di layer: **fermati e chiedi.** Non inferire dalla documentazione mnemonica, non inventare API o nomi di librerie.
