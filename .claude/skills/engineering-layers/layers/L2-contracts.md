# L2 — Contracts & API

**Purpose:** interfaces between components/services are explicit, typed, versioned and stable.

**Default decisions:** types/interfaces defined BEFORE the logic (Step 2 of the protocol). OpenAPI for
HTTP APIs. Types shared between backend and frontend (generated or in `shared/`). Explicit versioning on public APIs.

**Checklist:**
- [ ] Types/interfaces/schemas defined before implementation; no `any` (see L1/type safety).
- [ ] HTTP API documented (OpenAPI/schema); typed request/response.
- [ ] Contract shared back↔front (generated types or in `shared/`), not duplicated by hand.
- [ ] Public API: explicit version (`/v1/…`) + deprecation policy with a timeline.
- [ ] Breaking change: handled through versioning, without breaking existing consumers.
- [ ] Payload validation at the boundaries (see L5).

**Non-Negotiable:** none.

**Stop condition:** if a contract is ambiguous or an external consumer depends on the API, stop and
agree on the schema/versioning before implementing.
