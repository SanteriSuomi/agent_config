---
name: logging-best-practices
description: "Logging best practices using wide events (canonical log lines). AUTO-LOAD when: adding logging, writing log statements, setting up logger. Triggers: 'add logging', 'how to log', 'what should I log', console.log, logger.info, structured logging, log levels."
source: https://github.com/boristane/agent-skills/tree/main/skills/logging-best-practices
last-synced: 2026-01-23
metadata:
  author: boristane
  version: "1.0.0"
---

# Logging Best Practices

Guidelines for effective logging using **wide events** (canonical log lines).

---

## Core Insight

> Emit **one context-rich event per request per service**.

Not scattered `console.log()` throughout handlers. One structured event at request completion with everything you need.

**Goal**: Know "a premium customer couldn't complete a $2,499 purchase" not just "checkout failed."

---

## Before Adding Logs, Ask

1. **What question will this answer?** — If no clear question, don't log it
2. **Is this the right place?** — Prefer one wide event over many scattered logs
3. **What's the business context?** — User tier? Transaction value? Feature flags?
4. **Can I query this later?** — Structured > unstructured

---

## Decision Tree: Log Levels

```
Is it an unrecoverable error? → error
Everything else → info

That's it. Two levels.
```

**Why only two?**
- `debug`/`trace` should be off in prod anyway
- `warn` is ambiguous (is it a problem or not?)
- Simplicity enables consistent querying

---

## Decision Tree: What to Include

```
Request context?
├── Yes: method, path, requestId, timestamp
└── Always include these

User context?
├── Authenticated: user_id, subscription_tier, account_age
└── Anonymous: session_id, anonymous traits

Business context?
├── Transaction: cart_value, item_count, currency
├── Feature: feature_flags, experiment_variants
└── Domain-specific: whatever matters for your business

Environment?
├── Always: commit_hash, service_version, region
└── Debugging: instance_id, container_id

Outcome?
├── Always: status_code, outcome (success/error), duration_ms
└── Errors: error.message, error.type, stack (truncated)
```

---

## The Pattern

```typescript
const wideEvent: Record<string, unknown> = {
  method: 'POST',
  path: '/checkout',
  requestId: c.get('requestId'),
  timestamp: new Date().toISOString(),
};

try {
  const user = await getUser(c.get('userId'));
  wideEvent.user = { id: user.id, subscription: user.subscription };

  const cart = await getCart(user.id);
  wideEvent.cart = { total_cents: cart.total, item_count: cart.items.length };

  wideEvent.status_code = 200;
  wideEvent.outcome = 'success';
  return c.json({ success: true });
} catch (error) {
  wideEvent.status_code = 500;
  wideEvent.outcome = 'error';
  wideEvent.error = { message: error.message, type: error.name };
  throw error;
} finally {
  wideEvent.duration_ms = Date.now() - startTime;
  logger.info(wideEvent);  // ONE event, emitted ONCE
}
```

---

## Implementation Rules

### Single Logger (high)
- One logger instance configured at startup
- Import it everywhere
- Ensures consistent formatting and automatic environment context

### Middleware Pattern (high)
- Use middleware to handle infrastructure (timing, status, environment)
- Handlers only add business context
- Emit in `finally` block

### Structure & Consistency (high)
- JSON format always
- Consistent field names across services
- Two levels only: `info` and `error`
- Never unstructured strings

---

## Anti-patterns (with WHY)

| Anti-pattern | Why it's bad |
|--------------|--------------|
| Scattered `console.log()` | Can't correlate, noisy, inconsistent |
| Multiple logger instances | Different formats, missing context |
| Missing environment context | Can't correlate with deploys |
| Missing business context | "Checkout failed" vs "Premium user lost $2,499 order" |
| Unstructured strings | Can't query, can't aggregate |
| Inconsistent field names | `userId` vs `user_id` vs `uid` — can't join |
| More than 2 log levels | Creates confusion, inconsistent usage |
| Logging in loops | Explosion of events, noise |
| Sensitive data in logs | Security/compliance violation |

---

## Quick Checklist

```
[ ] One wide event per request (not scattered logs)
[ ] Emitted in finally block (always runs)
[ ] Has request context (method, path, requestId)
[ ] Has user context (id, tier, relevant traits)
[ ] Has business context (domain-specific values)
[ ] Has environment (commit, version, region)
[ ] Has outcome (status, success/error, duration)
[ ] JSON structured (not string templates)
[ ] Consistent field names (matches other services)
[ ] Only info and error levels
```

---

## References

- [Logging Sucks](https://loggingsucks.com)
- [Observability Wide Events 101](https://boristane.com/blog/observability-wide-events-101/)
- [Stripe - Canonical Log Lines](https://stripe.com/blog/canonical-log-lines)
