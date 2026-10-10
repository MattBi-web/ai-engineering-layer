# AGENTS.md — AI Engineering Layer

> **The PROCESS is provided by [`addyosmani/agent-skills`]** (installed): DEFINE→PLAN→BUILD→VERIFY→
> REVIEW→SHIP cycle via skills and the `/spec /plan /build /test /review /ship /code-simplify` commands, with parallel
> fan-out review (`code-reviewer` + `security-auditor` + `test-engineer`). **Do not duplicate that layer.**
>
> This file adds ONLY the *delta* that agent-skills does not cover:
> (a) **Context Bootstrap** on the project's infrastructure (code graph + Obsidian),
> (b) **3 Non-Negotiables** + **deterministic enforcement** (pre-commit + CI),
> (c) **architectural defaults** (MVC) and **stack** (FastAPI/React/Supabase) + tiering.
> It orients, it doesn't document: per-layer details are in the `engineering-layers` skill (on demand).

Act as a Senior Software Architect. "Vibe coding" is forbidden.

## A. CONTEXT BOOTSTRAP — hook agent-skills into the project's memory (delta #1)
During the agent-skills **DEFINE/`spec`** phase, BEFORE proposing the architecture, retrieve what
already exists (this makes DRY real and cuts tokens):
- **code graph** (`codebase-memory` MCP): `list_projects` → `get_architecture` → `search_graph`/`search_code`
  for reusable modules/routes/utils/patterns; `trace_path` for impact.
- **memory** (`obsidian` MCP, vault `memoria-ai`, `Progetti/`): `search-vault` for ADRs, decisions, conventions, known bugs.
In indexed projects, prefer these over grep/glob/reading whole files. (Delegate lookups to a **haiku** subagent.)

## B. 3 NON-NEGOTIABLES (delta #2 — blocking, verified in pre-commit/CI, never bypassable)
1. **RLS/authz on every non-public table** (in the same migration). → `engineering-layers` L3
2. **Rate limit on every public endpoint** (configured upstream). → L6
3. **Secrets only from vault/KMS/runtime env, never committed.** → L5
Enforcement: `enforcement/` (pre-commit + Claude hooks + CI gate). During **SHIP/`ship`**, the 3 NNs must
pass before the merge; if one fails → **NO-GO**.

## C. ARCHITECTURAL DEFAULTS & STACK (delta #3)
**"Restaurant" MVC** as the default for transactional web apps (if the domain is not transactional → STOP, propose an alternative):
Controller (waiter, routing only) → Service (kitchen, logic + sole DB access) → View (the dish). Layers never skip each other.
Layout: root with separate `backend/` + `frontend/`; feature = new module (controller+service) + page+service; `shared/` for DRY; `migrations/` for the schema; co-located tests.
**Target stack:** Backend **Python/FastAPI** · Frontend **React/TypeScript** · DB/Auth **Supabase (Postgres + RLS)**.
Record per project: minimum versions, active linter, `test`/`lint`/`build` commands (run them before "done"), forbidden deprecated libs, existing reusable patterns.

## D. PRODUCTION LAYERS & TIERING (the quality bar)
Every change DECLARES the **layers** it touches (L0–L11) and a **tier** (cosmetic/standard/critical: auth/payment/PII/migrations → critical = ≥2 human reviews). Rigor scales with risk. Load the checklist for ONLY the touched layer from the `engineering-layers` skill (progressive disclosure) — do not inline them all.
Map: L0 governance · L1 architecture · L2 contracts/API · L3 data(RLS) · L4 auth · L5 security/secrets · L6 reliability(rate-limit) · L7 performance · L8 observability · L9 deployment · L10 operations · L11 compliance.

## E. STOP CONDITIONS
If information is missing to decide a pattern/stack/layer requirement: **stop and ask.** Do not infer from memorized documentation, do not invent APIs or library names.
