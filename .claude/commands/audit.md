---
description: On-demand audit of the repo against the framework — measures the gap against the 12 layers and the 3 NNs
argument-hint: (optional) scope, e.g. "last month" or a path
---

Run an engineering audit of the current repo against the AI Engineering Layer framework. Scope: **${ARGUMENTS:-entire repo}**.

### 1. Code state (use the graph if the project is indexed)
`codebase-memory` MCP: `get_architecture` + `search_graph` for routes/tables/services. Otherwise `git ls-files`.

### 2. 3 Non-Negotiables (on the entire repo, not just the diff)
Run (or simulate with grep) the scripts in `enforcement/scripts/`:
- RLS on every table (`check-rls.sh` on all migrations)
- rate limit on every public endpoint (`check-rate-limit.sh`)
- no tracked secrets (`check-env-tracked.sh` + `.env` present in `.gitignore`)

### 3. Coverage of the 12 layers
For each layer L0–L11, assess: is it present in the project? At what maturity? Produce a table
`Layer | status (✅/🟡/❌) | gap`. Use the `engineering-layers` skill as the reference for the criteria.

### 4. Governance
Do these exist: `CODEOWNERS`, ADRs for non-trivial decisions, runbooks for services in prod, a `data-inventory`
for PII? Flag the missing ones.

### 5. Report
Final summary: qualitative score per layer, top 5 gaps by impact, and 3 concrete priority actions.
If the project is critical (auth/payment/PII), surface the security risks first.
