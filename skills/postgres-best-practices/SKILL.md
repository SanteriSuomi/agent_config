---
name: postgres-best-practices
description: "Postgres performance optimization from Supabase. AUTO-LOAD when: writing SQL queries, designing schemas, adding indexes, debugging slow queries, configuring connection pooling. Triggers: 'optimize query', 'add index', 'slow query', 'postgres performance', RLS, schema design, EXPLAIN."
source: https://github.com/supabase/agent-skills/tree/main/skills/postgres-best-practices
last-synced: 2026-01-23
metadata:
  author: supabase
  version: "1.0.0"
  license: MIT
---

# Postgres Best Practices

Performance optimization guide for Postgres from Supabase. 8 categories prioritized by impact.

## Rule Categories

| Priority | Category | Prefix |
|----------|----------|--------|
| 1 | Query Performance | `query-` |
| 2 | Connection Management | `conn-` |
| 3 | Security & RLS | `security-` |
| 4 | Schema Design | `schema-` |
| 5 | Concurrency & Locking | `lock-` |
| 6 | Data Access Patterns | `data-` |
| 7 | Monitoring | `monitor-` |
| 8 | Advanced Features | `advanced-` |

## On Activation

Load the full guide: `~/.agents/skills/postgres-best-practices/references/postgres-guide.md` (~1500 lines)

## Quick Reference

### Query Performance (Critical)

- **Always use indexes** for WHERE, JOIN, ORDER BY columns
- **Avoid SELECT *** — specify columns explicitly
- **Use EXPLAIN ANALYZE** to verify query plans
- **Parameterize queries** — never concatenate user input

### Connection Management (Critical)

- **Use connection pooling** (PgBouncer, Supavisor)
- **Close connections promptly** — don't hold idle connections
- **Set appropriate pool sizes** — typically 10-20 per service

### Schema Design (High)

- **Use appropriate data types** — don't use TEXT for everything
- **Add NOT NULL constraints** where applicable
- **Use partial indexes** for filtered queries
- **Normalize first**, denormalize only when measured

### Security (Critical)

- **Enable RLS** on all user-facing tables
- **Use SECURITY DEFINER** functions carefully
- **Never expose connection strings** in client code
