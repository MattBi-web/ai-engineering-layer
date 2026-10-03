# L6 — Reliability

**Scopo:** il sistema regge carico, errori e dipendenze esterne lente/giù senza cascate.

**Decisioni di default:** rate-limit middleware su ogni endpoint pubblico, configurato all'inizio.
Operazioni di scrittura idempotenti. Retry con backoff + jitter sulle chiamate esterne. Circuit
breaker sulle dipendenze. Code asincrone con dead-letter queue.

**Checklist:**
- [ ] **NN#2**: ogni endpoint pubblico ha rate limiting (per utente/IP/chiave), non aggiunto "dopo".
- [ ] Operazioni mutanti idempotenti (idempotency key dove serve) → retry sicuri.
- [ ] Chiamate esterne (HTTP/DB/queue) con timeout + retry/backoff espliciti, mai illimitati.
- [ ] Circuit breaker / fallback sulle dipendenze critiche; stato d'errore user-friendly.
- [ ] Lavoro async: coda con DLQ; messaggi processati at-least-once + idempotenza.
- [ ] Decisione sync vs async motivata.

**Non-Negotiable:** NN#2 — rate limit su ogni endpoint pubblico.

**Stop condition:** se non è chiaro il limite di rate appropriato o la semantica di idempotenza,
fermati e chiedi requisiti (QPS atteso, costo di un doppione).
