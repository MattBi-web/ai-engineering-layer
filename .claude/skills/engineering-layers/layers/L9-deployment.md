# L9 — Deployment & Environments

**Purpose:** safe, reversible releases promoted through environments, with no surprise downtime.

**Default decisions:** dev → staging → prod environments. Automatic deploy on push (CD). Rollback always
available. Feature flags to decouple deploy from release. Per-environment config, never hardcoded.

**Checklist:**
- [ ] A **staging** environment that mirrors prod exists; the change goes through it before prod.
- [ ] Release strategy: canary/blue-green or at least a health-gated deploy.
- [ ] **Rollback** defined and tested (target RTO declared, consistent with L3 backups).
- [ ] Feature flags for risky functionality (deploy ≠ release).
- [ ] Config via per-environment env; secrets from vault (NN#3); dev→staging→prod promotion tracked.
- [ ] DB migrations compatible with the deploy (expand-contract, L3) for zero downtime.

**Non-Negotiable:** inherits NN#3 (per-environment config/secrets from vault).

**Stop condition:** if there is no staging environment or rollback path, stop and flag it before
releasing critical code to production.
