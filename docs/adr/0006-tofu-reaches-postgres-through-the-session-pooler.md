# 6. Tofu reaches Postgres through the session pooler

This decision records which of Supabase's three database endpoints tofu uses,
and why the other two cannot work.

## Context

Supabase exposes the same database three ways, and they are not
interchangeable:

| Endpoint           | Port | IPv4          | Prepared statements |
| ------------------ | ---- | ------------- | ------------------- |
| Direct             | 5432 | no, IPv6 only | yes                 |
| Session pooler     | 5432 | yes           | yes                 |
| Transaction pooler | 6543 | yes           | no                  |

The PostgreSQL provider needs prepared statements to run DDL. GitHub Actions
runners have no IPv6.

## Decision

**Tofu always connects through the session pooler. Applications always connect
through the transaction pooler.**

- **The session pooler is the only endpoint satisfying both constraints,** so
  every `provider "postgresql"` block points at `db_session_host` and
  `db_session_port`.
- **Application runtime uses the transaction pooler on 6543,** which scales to
  many short-lived connections in a way the session pooler does not.

## Consequences

This is the repository's sharpest landmine. Each wrong choice fails in a
different and unhelpful way: the direct endpoint fails only in CI and works
perfectly on a developer's machine, and the transaction pooler fails on DDL
with an error that does not mention prepared statements.

The endpoint is therefore read from the Supabase config module rather than
written out per stack, so there is no per-stack opportunity to get it wrong.
