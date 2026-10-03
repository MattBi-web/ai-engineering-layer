# L5 — Security & Secrets

**Scopo:** nessun segreto versionato, dati cifrati, input validato, vulnerabilità AI-specifiche bloccate.

**Decisioni di default:** secrets da vault/KMS o env-at-runtime (mai in repo). TLS ovunque (in transit),
encryption at rest sul DB. Validazione input a ogni boundary esterno. Riferimento OWASP Top 10 + OWASP LLM.

**Checklist:**
- [ ] **NN#3**: nessun secret/API key in file tracciati; `.env` in `.gitignore`; gitleaks pulito.
- [ ] Secrets letti da vault/KMS/env a runtime; rotazione prevista.
- [ ] Encryption in transit (TLS) e at rest documentate.
- [ ] Ogni input esterno (form, query, header, payload) validato e sanitizzato.
- [ ] **Package hallucination**: ogni dipendenza nuova esiste davvero, versione pinnata, fonte verificata (vettore d'attacco AI #1).
- [ ] Se il codice usa un LLM (RAG/tool use): difese da prompt injection; OWASP LLM Top 10 considerata.
- [ ] Nessun PII/secret nei log.

**Non-Negotiable:** NN#3 — secrets solo da vault/KMS, mai committati.

**Stop condition:** se serve un secret e non c'è un vault/meccanismo definito, fermati e chiedi; non
hardcodare "temporaneamente".
