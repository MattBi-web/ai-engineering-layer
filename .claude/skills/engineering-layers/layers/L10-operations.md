# L10 — Operations

**Scopo:** quando qualcosa va storto in produzione, c'è un proprietario, una procedura e un apprendimento.

**Decisioni di default:** ogni servizio in prod ha un runbook e un owner/on-call. Incidenti classificati
per severità. Postmortem blameless obbligatorio per SEV1/SEV2. Chaos/failure testing sui sistemi critici.

**Checklist:**
- [ ] **Runbook** presente per il servizio (`governance/runbooks/`): health, alert→azione, deploy, rollback, escalation.
- [ ] Owner / rotazione on-call definiti (coerente con CODEOWNERS, L0).
- [ ] Severità incidenti (SEV1/2/3) e canali/tempi di escalation documentati.
- [ ] Postmortem blameless per SEV1/SEV2 (`governance/postmortems/`), con action items tracciati e assegnati.
- [ ] Alert azionabili (collegati a un'azione del runbook), non rumore.
- [ ] (Sistemi critici) failure/chaos test per validare i meccanismi di resilienza (L6).

**Non-Negotiable:** nessuna.

**Stop condition:** se un servizio sta per andare in prod senza runbook né owner, fermati: non è operabile.
