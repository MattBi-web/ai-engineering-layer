# L10 — Operations

**Purpose:** when something goes wrong in production, there is an owner, a procedure and a lesson learned.

**Default decisions:** every service in prod has a runbook and an owner/on-call. Incidents classified
by severity. Blameless postmortem mandatory for SEV1/SEV2. Chaos/failure testing on critical systems.

**Checklist:**
- [ ] **Runbook** present for the service (`governance/runbooks/`): health, alert→action, deploy, rollback, escalation.
- [ ] Owner / on-call rotation defined (consistent with CODEOWNERS, L0).
- [ ] Incident severities (SEV1/2/3) and escalation channels/times documented.
- [ ] Blameless postmortem for SEV1/SEV2 (`governance/postmortems/`), with action items tracked and assigned.
- [ ] Actionable alerts (linked to a runbook action), not noise.
- [ ] (Critical systems) failure/chaos tests to validate the resilience mechanisms (L6).

**Non-Negotiable:** none.

**Stop condition:** if a service is about to go to prod with neither a runbook nor an owner, stop: it is not operable.
