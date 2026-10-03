# Data Inventory (L11 — Compliance & Data Governance)

Registro dei dati personali/sensibili trattati. Va aggiornato ogni volta che una PR tocca L11.
È la base per retention, audit trail e adempimenti GDPR/HIPAA dove applicabile.

| Dato | Tabella/Store | Classificazione | Base giuridica | Retention | Encryption | Chi vi accede |
|---|---|---|---|---|---|---|
| es. email utente | `users.email` | PII | consenso | 24 mesi | at-rest + in-transit | service auth |
| es. registrazione call | `calls.recording_url` | PII sensibile | contratto | 6 mesi | at-rest (KMS) | service vapi |
|  |  |  |  |  |  |  |

## Regole
- Ogni colonna PII è marcata qui e ha RLS (NN#1) + encryption.
- Nessun PII nei log (L5/L8).
- Retention applicata via job schedulato; cancellazione/anonimizzazione documentata.
- Audit trail per accessi a dati sensibili (chi/quando/perché).
- Richieste GDPR (accesso/cancellazione): procedura linkata qui → <link>.
