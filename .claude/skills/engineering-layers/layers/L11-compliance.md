# L11 — Compliance & Data Governance (conditional)

**Purpose:** personal/regulated data is processed lawfully, tracked and deletable. Activates ONLY
if the PR touches PII or regulated data.

**Default decisions:** every PII field is recorded in `governance/data-inventory.md`. Retention enforced
and documented. Audit trail on sensitive access. GDPR/HIPAA where applicable.

**Checklist:**
- [ ] Every new/modified PII field is registered in `data-inventory.md` (classification, legal basis, retention).
- [ ] PII protected: RLS (NN#1) + encryption in transit/at rest (L5); no PII in logs (L5/L8).
- [ ] Retention: deletion/anonymization mechanism in place and documented.
- [ ] Audit trail for access to sensitive data (who/when/why).
- [ ] Data subject rights (GDPR access/erasure): procedure referenced.
- [ ] If HIPAA/finance: specific requirements verified; critical tier (L0) + dedicated review.

**Non-Negotiable:** inherits NN#1 (RLS on tables with PII) and NN#3 (secrets/encryption).

**Stop condition:** if it is unclear whether a piece of data is PII or which legal basis/retention applies, stop
and involve the owner/DPO; do not process regulated data based on inference.
