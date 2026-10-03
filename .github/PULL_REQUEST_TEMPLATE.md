<!--
PR stratificata: spunta SOLO i layer che questa PR tocca, poi compila quelle sezioni.
Una UI tweak compila pochi box; un flusso di pagamento li compila quasi tutti.
Il rigore scala col rischio — non è una checklist da 60 voci da ignorare.
-->

## 🎚️ Tier
- [ ] **cosmetic** (UI/copy/stile) — review leggera
- [ ] **standard** (feature/bugfix) — protocollo a 5 step completo
- [ ] **critical** (auth / payment / PII / migrazioni) — ⚠️ richiede ≥2 review umane + security scan

## 🛑 Non-Negotiables (sempre — se una non si applica, spiega perché)
- [ ] **NN#1** Ogni tabella nuova/modificata ha RLS + policy nella stessa migration
- [ ] **NN#2** Ogni endpoint pubblico nuovo ha rate limiting
- [ ] **NN#3** Nessun secret in file tracciati (`.env` ignorato, gitleaks pulito)

## 🤖 Check AI-specifici
- [ ] **Package hallucination**: ogni dipendenza nuova esiste, versione pinnata, fonte verificata
- [ ] Nessun secret/API key generato in chiaro
- [ ] Se il codice usa un LLM (RAG/tool use): OWASP LLM Top 10 considerata (prompt injection)

## 📦 Layer toccati (spunta e compila solo questi)
- [ ] **L0 Governance** — owner/ADR/glossario aggiornati; tier dichiarato
- [ ] **L1 Architecture** — MVC rispettato; Context Bootstrap fatto (nessuna duplicazione); controller senza logica
- [ ] **L2 Contracts & API** — tipi/interfacce espliciti; versioning/deprecation se API pubblica
- [ ] **L3 Data** — RLS; migrazione zero-downtime (expand-contract); backup/rollback
- [ ] **L4 Auth** — authn/authz separati; sessioni/refresh token
- [ ] **L5 Security & Secrets** — input validato; crypto in transit/at rest; secrets da vault
- [ ] **L6 Reliability** — rate limit; idempotenza; retry/timeout; circuit breaker
- [ ] **L7 Performance & Scale** — cache/CDN; performance budget; sharding/replica se serve
- [ ] **L8 Observability** — 4 Golden Signals; SLO; tracing; alert su burn rate
- [ ] **L9 Deployment & Env** — staging/canary; rollback; feature flag; env promotion
- [ ] **L10 Operations** — runbook; on-call; incident response
- [ ] **L11 Compliance** — PII handling; retention; audit trail (GDPR/HIPAA se rilevante)

## 🧪 Test
- [ ] Unit/Integration scritti per la funzionalità
- [ ] Coprono happy path **e** edge/error case
- [ ] La suite esistente compila e passa

## 🔍 Self-Review AI (compliance report)
**Pattern scelto e perché:**

**Cosa NON è stato fatto / assunzioni prese:**

**Layer toccati e perché:**

<!-- Per PR standard/critical: allegare l'output dello Step 5 (reviewer-agent separato, model opus). -->
