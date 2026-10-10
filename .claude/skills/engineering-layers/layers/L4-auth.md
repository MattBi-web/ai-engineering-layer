# L4 — Auth (Authentication & Authorization)

**Purpose:** you know WHO the user is (authn) and WHAT they can do (authz), kept separate and enforced on every request.

**Default decisions:** Supabase Auth for authn. Authz enforced both at the DB level (RLS, see L3) and
at the service level. Sessions with short-lived access tokens + refresh tokens. Never frontend-only authz.

**Checklist:**
- [ ] **Authentication ≠ Authorization**: kept separate. Identity does not imply permission.
- [ ] Every endpoint/resource checks permissions server-side (never trust the client).
- [ ] RLS aligned with roles (consistent with L3): the DB policy mirrors the application authz.
- [ ] Short-lived access tokens + refresh tokens with rotation/revocation; logout invalidates the session.
- [ ] No authorization checks in the UI only (`pages/` are not a security barrier).
- [ ] Critical paths (auth/payment) → critical tier (L0), mandatory human review.

**Non-Negotiable:** enables NN#1 (data-level authz is RLS).

**Stop condition:** if the roles/permissions model is not defined, stop and ask; do not invent an authorization scheme.
