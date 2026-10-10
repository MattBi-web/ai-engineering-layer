<!--
Layered PR: tick ONLY the layers this PR touches, then fill in those sections.
A UI tweak fills in a few boxes; a payment flow fills in almost all of them.
Rigor scales with risk — this is not a 60-item checklist to be ignored.
-->

## 🎚️ Tier
- [ ] **cosmetic** (UI/copy/style) — light review
- [ ] **standard** (feature/bugfix) — full 5-step protocol
- [ ] **critical** (auth / payment / PII / migrations) — ⚠️ requires ≥2 human reviews + security scan

## 🛑 Non-Negotiables (always — if one doesn't apply, explain why)
- [ ] **NN#1** Every new/modified table has RLS + a policy in the same migration
- [ ] **NN#2** Every new public endpoint has rate limiting
- [ ] **NN#3** No secrets in tracked files (`.env` ignored, gitleaks clean)

## 🤖 AI-specific checks
- [ ] **Package hallucination**: every new dependency exists, version pinned, source verified
- [ ] No secrets/API keys generated in plaintext
- [ ] If the code uses an LLM (RAG/tool use): OWASP LLM Top 10 considered (prompt injection)

## 📦 Layers touched (tick and fill in only these)
- [ ] **L0 Governance** — owner/ADR/glossary updated; tier declared
- [ ] **L1 Architecture** — MVC respected; Context Bootstrap done (no duplication); controllers without logic
- [ ] **L2 Contracts & API** — explicit types/interfaces; versioning/deprecation if public API
- [ ] **L3 Data** — RLS; zero-downtime migration (expand-contract); backup/rollback
- [ ] **L4 Auth** — authn/authz separated; sessions/refresh tokens
- [ ] **L5 Security & Secrets** — input validated; crypto in transit/at rest; secrets from vault
- [ ] **L6 Reliability** — rate limit; idempotency; retry/timeout; circuit breaker
- [ ] **L7 Performance & Scale** — cache/CDN; performance budget; sharding/replicas if needed
- [ ] **L8 Observability** — 4 Golden Signals; SLO; tracing; burn-rate alerts
- [ ] **L9 Deployment & Env** — staging/canary; rollback; feature flags; env promotion
- [ ] **L10 Operations** — runbook; on-call; incident response
- [ ] **L11 Compliance** — PII handling; retention; audit trail (GDPR/HIPAA if relevant)

## 🧪 Tests
- [ ] Unit/integration tests written for the feature
- [ ] They cover the happy path **and** edge/error cases
- [ ] The existing suite builds and passes

## 🔍 AI Self-Review (compliance report)
**Chosen pattern and why:**

**What was NOT done / assumptions made:**

**Layers touched and why:**

<!-- For standard/critical PRs: attach the Step 5 output (separate reviewer agent, model opus). -->
