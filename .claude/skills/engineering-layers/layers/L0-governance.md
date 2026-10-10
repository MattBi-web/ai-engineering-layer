# L0 — Governance (cross-cutting)

**Purpose:** every change has an owner, a tracked rationale and a proportionate level of rigor.

**Default decisions:** ownership via `CODEOWNERS`. Architecture decisions in ADRs. Shared domain
glossary. Every PR declares a **tier**.

**Tier (rigor scales with risk):**
- **cosmetic** — UI/copy/style: standard flow, light review.
- **standard** — regular features/bugfixes: full 5-step protocol.
- **critical** — auth, payment, PII, migrations: mandatory human review (≥2 approvals) + security scan.

**Checklist:**
- [ ] Tier declared in the PR; if critical, human reviewer assigned.
- [ ] Path covered by `CODEOWNERS`.
- [ ] Non-trivial decision → ADR created/updated (`governance/ADR/`).
- [ ] New domain terms → glossary updated.

**Non-Negotiable:** none.

**Stop condition:** if the tier is unclear or the touched path has no owner, stop and ask.
