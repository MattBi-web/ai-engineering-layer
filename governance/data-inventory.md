# Data Inventory (L11 — Compliance & Data Governance)

Register of the personal/sensitive data processed. Update it every time a PR touches L11.
It is the basis for retention, audit trail and GDPR/HIPAA obligations where applicable.

| Data | Table/Store | Classification | Legal basis | Retention | Encryption | Accessed by |
|---|---|---|---|---|---|---|
| e.g. user email | `users.email` | PII | consent | 24 months | at-rest + in-transit | auth service |
| e.g. call recording | `calls.recording_url` | sensitive PII | contract | 6 months | at-rest (KMS) | vapi service |
|  |  |  |  |  |  |  |

## Rules
- Every PII column is flagged here and has RLS (NN#1) + encryption.
- No PII in logs (L5/L8).
- Retention enforced via a scheduled job; deletion/anonymization documented.
- Audit trail for access to sensitive data (who/when/why).
- GDPR requests (access/erasure): procedure linked here → <link>.
