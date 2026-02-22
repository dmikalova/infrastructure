# Todos Infra: Design

## Context

The todos app is a single-user personal task manager built with Deno + Hono +
Vue.js. It uses Supabase as the database backend with Realtime for live updates.
Authentication is delegated to the login portal at login.mklv.tech.

This follows the existing infrastructure pattern established by email-unsubscribe
and login apps.

## Goals / Non-Goals

**Goals:**

- Deploy todos app to Cloud Run with todos.mklv.tech domain
- Configure CI/CD via GitHub Actions

**Non-Goals:**

- No custom OAuth setup (uses shared login portal)
- No special sidecar containers (unlike email-unsubscribe)
- No scheduled jobs

## Decisions

### Decision: Standard Cloud Run app module

**Choice**: Use the existing `cloud-run-app` module with minimal configuration.
The module handles everything including Supabase database setup via the
`app-database` submodule.

**Rationale**: Todos app is simpler than email-unsubscribe - no sidecars, no
scheduled jobs, no public bucket. Standard module covers all needs.

**Alternatives**:

- Custom Cloud Run configuration: Unnecessary complexity

### Decision: Environment variables

The cloud-run-app module automatically provides DATABASE_URL via the app-database
submodule.

Additional secrets needed for Supabase Realtime:

| Variable                 | Source                | Purpose                 |
| ------------------------ | --------------------- | ----------------------- |
| SUPABASE_URL             | Existing secret       | Supabase project URL    |
| SUPABASE_PUBLISHABLE_KEY | SOPS → Secret Manager | Public key for Realtime |
| SUPABASE_JWT_KEY         | SOPS → Secret Manager | JWT validation          |

## Risks / Trade-offs

**Risk**: Supabase Realtime connection limits

- Mitigation: Single-user app, well under free tier limits
