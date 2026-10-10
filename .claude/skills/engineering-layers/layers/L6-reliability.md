# L6 — Reliability

**Purpose:** the system withstands load, errors and slow/down external dependencies without cascading failures.

**Default decisions:** rate-limit middleware on every public endpoint, configured from the start.
Idempotent write operations. Retry with backoff + jitter on external calls. Circuit
breakers on dependencies. Async queues with a dead-letter queue.

**Checklist:**
- [ ] **NN#2**: every public endpoint has rate limiting (per user/IP/key), not added "later".
- [ ] Idempotent mutating operations (idempotency key where needed) → safe retries.
- [ ] External calls (HTTP/DB/queue) with explicit timeouts + retry/backoff, never unbounded.
- [ ] Circuit breaker / fallback on critical dependencies; user-friendly error state.
- [ ] Async work: queue with DLQ; messages processed at-least-once + idempotency.
- [ ] Sync vs async decision justified.

**Non-Negotiable:** NN#2 — rate limit on every public endpoint.

**Stop condition:** if the appropriate rate limit or the idempotency semantics are unclear,
stop and ask for requirements (expected QPS, cost of a duplicate).
