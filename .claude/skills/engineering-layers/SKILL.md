---
name: engineering-layers
description: Per-layer production-readiness checklists for the AI Engineering Layer framework. Use when implementing or reviewing a change to load the detailed checklist for ONLY the production layer(s) that change touches (data/RLS, auth, security/secrets, reliability/rate-limit, observability, deployment, operations, compliance, etc.) — instead of inlining all 12 layers into context.
---

# Engineering Layers — progressive checklists

> Questa skill è la **asticella di production-readiness org** (cosa deve essere vero), complementare alle
> skill di *processo* di agent-skills (come si lavora). Le 3 Non-Negotiables sono enforced in `enforcement/`.

Production is an iceberg: code is the tip. A change DECLARES which layers it touches; load the
checklist for **only those layers** from `layers/`, apply it in Step 4 (implementation) and Step 5
(review). Do not read all layer files at once.

## The 3 Non-Negotiables (always apply, never bypass)
- **NN#1** RLS/authz on every non-public table → see `layers/L3-data.md`
- **NN#2** Rate limit on every public endpoint → see `layers/L6-reliability.md`
- **NN#3** Secrets only from vault/KMS, never committed → see `layers/L5-security.md`

## Layer index (load on demand)
| Layer | File | Load when the change… |
|---|---|---|
| L0 Governance | `layers/L0-governance.md` | adds ownership/ADR/glossary or sets tier |
| L1 Architecture | `layers/L1-architecture.md` | adds/moves modules, services, components |
| L2 Contracts & API | `layers/L2-contracts.md` | defines/changes types, endpoints, schemas |
| L3 Data | `layers/L3-data.md` | touches DB schema, tables, migrations (NN#1) |
| L4 Auth | `layers/L4-auth.md` | touches authentication/authorization |
| L5 Security & Secrets | `layers/L5-security.md` | handles secrets, input, crypto (NN#3) |
| L6 Reliability | `layers/L6-reliability.md` | adds endpoints, queues, external calls (NN#2) |
| L7 Performance & Scale | `layers/L7-performance.md` | affects throughput, caching, data volume |
| L8 Observability | `layers/L8-observability.md` | adds a service/endpoint to run in prod |
| L9 Deployment & Env | `layers/L9-deployment.md` | changes deploy, config, env promotion |
| L10 Operations | `layers/L10-operations.md` | ships an operable service (runbook/on-call) |
| L11 Compliance | `layers/L11-compliance.md` | handles PII/regulated data (conditional) |

## How to use
1. In Step 1, after Context Bootstrap, declare the layers the change touches.
2. In Step 4, open each declared layer file and satisfy its checklist.
3. In Step 5, the reviewer agent re-checks each declared layer file against the diff and runs NN#1–3.

> Status: tutti i 12 layer (L0–L11) popolati. Le schede sono il punto di partenza: vanno tarate sui
> pattern reali del repo target (`layers/_TEMPLATE.md` per aggiungerne/riscriverle).
