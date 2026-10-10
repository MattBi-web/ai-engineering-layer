# L3 — Data

**Purpose:** a correct, secure data schema that can be migrated without downtime; no table left "open".

**Default decisions:** Postgres/Supabase. Every table is created with RLS enabled. Migrations
versioned in `migrations/`, expand-contract pattern. Backups with declared RPO/RTO.

**Checklist:**
- [ ] **NN#1**: every `CREATE TABLE` holding non-public data has `ENABLE ROW LEVEL SECURITY` + at least one `CREATE POLICY` in the SAME migration.
- [ ] Zero-downtime migration: no NOT NULL column without a default on a populated table; expand→migrate→contract pattern for rename/drop.
- [ ] Indexes on columns used by queries/policies; explicit foreign keys.
- [ ] No sensitive data in plaintext (see L5/L11); PII columns flagged in the data-inventory.
- [ ] Backup and restore strategy *tested* (not just configured); RPO/RTO recorded.
- [ ] Migration rollback defined.

**Repos without SQL migrations (Supabase client/ORM):** RLS lives in Supabase and cannot be verified from code
→ a **tracked attestation** is required in `governance/rls-attestation.md` (or "RLS: enabled" per table in
`data-inventory.md`). The `check-rls.sh` check requires it in this case.

**Non-Negotiable:** NN#1 — RLS/authz on every non-public table.

**Stop condition:** if a table must stay without RLS (e.g. public data), stop and create an ADR
documenting the exception; never disable RLS silently.
