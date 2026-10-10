# L5 — Security & Secrets

**Purpose:** no versioned secrets, encrypted data, validated input, AI-specific vulnerabilities blocked.

**Default decisions:** secrets from vault/KMS or env-at-runtime (never in the repo). TLS everywhere (in transit),
encryption at rest on the DB. Input validation at every external boundary. Reference: OWASP Top 10 + OWASP LLM.

**Checklist:**
- [ ] **NN#3**: no secrets/API keys in tracked files; `.env` in `.gitignore`; gitleaks clean.
- [ ] Secrets read from vault/KMS/env at runtime; rotation planned.
- [ ] Encryption in transit (TLS) and at rest documented.
- [ ] Every external input (form, query, header, payload) validated and sanitized.
- [ ] **Package hallucination**: every new dependency actually exists, version pinned, source verified (AI attack vector #1).
- [ ] If the code uses an LLM (RAG/tool use): prompt-injection defenses; OWASP LLM Top 10 considered.
- [ ] No PII/secrets in logs.

**Non-Negotiable:** NN#3 — secrets only from vault/KMS, never committed.

**Stop condition:** if a secret is needed and no vault/mechanism is defined, stop and ask; do not
hardcode it "temporarily".
