# AI Engineering Layer
*An operational framework for writing software with AI assistants without multiplying technical debt, tokens and security risk.*

> v1 · 2026 — M. Bigi

## Abstract
Coding agents (Claude Code, Cursor, Codex…) have changed the speed of development, but they have
introduced three silent debts: **wasted tokens** (the agent reads files blindly), **duplicated code**
(it doesn't know what already exists), and **systematic vulnerabilities** (according to Veracode, *45% of AI-generated
code introduces OWASP Top-10 issues* — forgotten RLS, missing rate limits, hardcoded secrets). The **AI Engineering Layer**
is a composition of three layers — *retrieval+memory, process, enforcement* — that hardens the development
loop *without* requiring new tools: it builds on Claude Code and on a well-maintained community plugin
([`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills)) and adds only the **delta**
that no standard covers: a *context bootstrap* on a code knowledge graph, and three **deterministic
guardrails** (`pre-commit + hooks + CI`) that reject merges without RLS, without rate limiting, or with secrets
in plain text.

## Why it exists
1. **Token economics.** An agent that explores with grep reads thousands of lines to answer a structural
   question. A code graph ([`codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp)
   measures ~99% fewer tokens on structural queries) answers in a few nodes. It is the single intervention with
   the best value/effort ratio for anyone using LLMs every day.
2. **Anti-vibe-coding.** Left unchecked, the agent writes code prose "that looks right".
   2026 best practices (Spec-Driven Development, Plan Mode, separate review, OWASP LLM/Agents) converge
   on the same pattern: *decide first, then type, then test, then implement, then someone else reviews*. Enforcing
   that pattern reduces debt.
3. **AI-specific security.** *Package hallucination* (the agent invents library names that attackers
   then register), committed secrets, forgotten RLS on Supabase: these are *systematic* patterns, not isolated
   incidents. A layer that catches them in CI before the merge eliminates them at the root.

## The thesis in one sentence
*Process standard (agent-skills) **+** retrieval/memory (knowledge graph + Obsidian) **+** deterministic
enforcement (pre-commit, hooks, CI) = an agent that produces production-ready code, not just plausible code.*

## Architecture — the 3 rings
| Ring | What it does | When it activates |
|---|---|---|
| **1. Infra (retrieval + memory)** | `codebase-memory` MCP (code graph, Cypher), `obsidian` MCP (long-term memory), `opusplan` model routing, *graph-first* rule in `CLAUDE.md` | **Always**. Set and forget; it runs in the background. |
| **2. Process** | Addy Osmani's `agent-skills`: 20+ skills + `/spec /plan /build /test /review /ship`, parallel fan-out review (code-reviewer + security-auditor + test-engineer) | **When working on code** (not in general chats). |
| **3. Enforcement** | 3 lines of defense: **pre-commit** (gitleaks + custom scripts) → **Claude Code hooks** (blocks destructive bash, stops on failing tests) → **CI** (`non-negotiables.yml` + `ai-code-gate.yml` organized by layer) | **Per target repo** where production code is committed. |

## The 3 Non-Negotiables
These are the most common and most costly failures of AI-generated code (Lovable and similar). The framework
rejects them at the CI level:
1. **RLS / authz on every non-public table** — even if the agent forgets it, the migration is not
   accepted (native SQL check; for Supabase-client repos a **tracked attestation** is required).
2. **Rate limit on every public endpoint** — global *or* per-route middleware, counted. A mere
   "mention of a limiter" is not enough.
3. **Secrets only from a vault/KMS, never committed** — deep gitleaks scan + check for tracked `.env` files.

## The 12 Production Layers (the iceberg)
The tip is the code; 90% of production work lies beneath. Every PR declares which layers it touches, and
rigor scales with risk (`cosmetic` / `standard` / `critical`). The 12 layers are loaded **on demand**
via a *Claude Code Skill* (progressive disclosure) to avoid bloating the context: L0 governance, L1
architecture, L2 contracts/API, L3 data, L4 auth, L5 security/secrets, L6 reliability, L7 performance,
L8 observability, L9 deployment, L10 operations, L11 compliance.

## Token economics — why it saves (and where)
1. **Structured retrieval.** Replacing grep and blind reads with `search_graph`/`trace_path`/`get_architecture`
   means bringing *relevant nodes* into context, not whole files. On structural queries (callers, routes,
   modules) the vendor's stated gain is ~99%; in practice the typical value is **a high double-digit
   percentage**, provided the project is indexed.
2. **Progressive disclosure of rules.** The 12 layer cards load only for the touched layer: a
   UI tweak doesn't pull the 170 lines of observability/compliance into context.
3. **Model routing.** Default `opusplan` (Opus plans, Sonnet executes). Sub-agents: `haiku` for graph /
   Obsidian lookups, `sonnet` for impl/tests, `opus` only for architecture/review. Grunt work doesn't
   run on Opus.
4. **Incremental re-indexing.** Only changed files are re-added to the graph. A nightly routine
   keeps the index fresh with no intervention.

## What it is NOT
- It is *not* a proxy to other providers. You always stay on Anthropic; no data is exfiltrated. Compatible with
  Claude Code Enterprise.
- It is *not* a standalone app. It is a *layer* on top of Claude Code: the value lies in the agent's behavior,
  not in a separate UI.
- It does *not* replace human code review for critical paths (auth/payment/PII require ≥2 reviews).
- It does *not* impose a new workflow: the process is `agent-skills`', already adopted by dozens of teams.

## Use cases (decision rule)
| Scenario | What you do |
|---|---|
| Chat for questions/research/ideas | Nothing. Ring 1 works on its own. |
| Work on an already indexed repo | Let the graph-first rule guide you (`search_graph` instead of grep). |
| Feature development / serious refactor | `/spec → /plan → /build → /test → /review → /ship`. |
| Development on a critical repo (auth, payment, PII, client code) | Also add **Ring 3** inside the repo: `pre-commit install` + CI workflow + PR template. |

## Honest limitations
- The enforcement scripts are **heuristic** (grep/regex): they need to be calibrated to the actual stack. A pilot on
  a real repo is the serious way to ship the framework onto a codebase.
- Graph-first applies to **indexed projects**. For non-indexed folders, grep and classic editors
  remain the way to go.
- Code-based RLS detection covers repos with SQL migrations; for Supabase-client repos RLS
  is external → a **tracked attestation** in `governance/` is required.
- "*-99% tokens*" is a claim by the graph's vendor: in real cases the gain is large but variable.

## Setup (1 line)
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.sh | bash
```
See [`distribution/INSTALL.md`](distribution/INSTALL.md) for flags, opt-ins and troubleshooting.
**Windows users:** [`distribution/INSTALL.windows.md`](distribution/INSTALL.windows.md) — two options,
WSL2 (recommended, same command as Mac/Linux) or native via `install.ps1`. Server-side CI runs
on Ubuntu regardless, so the "hard" pre-merge guardrails don't depend on the developer's OS.

## References
- Addy Osmani — *Agent Skills (Production-Grade Engineering Skills for AI Coding Agents)*, MIT.
- *codebase-memory-mcp* (DeusData) — Tree-Sitter Knowledge Graphs for LLM Code Exploration via MCP.
- OWASP LLM Top 10 (2025-2026) / OWASP Top 10 for Agents.
- Veracode 2026 — *45% of AI-generated code samples introduce OWASP Top 10 vulnerabilities*.
- Anthropic — *Claude Code: hooks, sub-agents, agent skills, model selection*.
- Google SRE — *Four Golden Signals*, *SLOs & Error Budgets*.

## Status and roadmap
- **v1** (2026): infra, process, enforcement, 12 layers, governance, monthly audit, installer.
- **next**: refining the heuristics for different stacks, ADRs/runbooks auto-generated by `/ship`, bundling
  as a single Claude Code plugin, a gap-tracking dashboard for the framework.
