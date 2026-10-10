# L7 — Performance & Scale

**Purpose:** the system responds within budget and handles growth in load and data.

**Default decisions:** performance budget per endpoint (p95). Caching where needed (with clear invalidation).
CDN for static assets. Scaling decisions (read replicas, sharding) driven by data, not guesswork.

**Checklist:**
- [ ] Performance budget defined (e.g. p95 < 300ms) and verified for hot paths.
- [ ] DB queries indexed; no N+1; pagination on potentially large lists.
- [ ] Caching with an explicit invalidation strategy (no cache that "never expires").
- [ ] Static assets via CDN; compressed payloads.
- [ ] Data growth: justified choice of read replica / sharding key / partitioning; consistency model declared.
- [ ] Load/performance tests for changes on critical paths.

**Non-Negotiable:** none (but the L6 rate limit is the first line of defense against overload).

**Stop condition:** if there are no performance targets or load estimates, stop and agree on them before
optimizing (avoid premature micro-optimizations).
