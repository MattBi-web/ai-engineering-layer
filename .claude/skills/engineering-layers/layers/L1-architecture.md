# L1 — Architecture

**Purpose:** clean MVC structure, single responsibility, zero duplication.

**Default decisions:** "restaurant" MVC (AGENTS.md §2). Split `backend/`+`frontend/`. Feature = new
module (controller+service) + frontend page+service. Shared code in `shared/`.

**Checklist:**
- [ ] Context Bootstrap done: searched the graph/Obsidian for an existing component to reuse (DRY).
- [ ] Controller = routing only, no business logic. Service = logic + sole DB access.
- [ ] Pages = UI only; backend calls only via frontend `services/` (never direct HTTP from a page).
- [ ] New feature = new module, not a "bolt-on" to existing modules.
- [ ] Single-responsibility test: changing the UI touches only `pages/`; changing the DB only the services.
- [ ] If the change forces edits in unrelated layers → wrong structure, refactor before proceeding.
- [ ] If the domain is NOT transactional (ML/event-driven/static) → propose an alternative, don't force MVC.

**Non-Negotiable:** none (but it enables the DRY mandate via Context Bootstrap).

**Stop condition:** if the right architecture is not MVC or is unclear from the domain, stop and propose.
