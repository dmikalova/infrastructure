# Todos Infra: Proposal

## Why

The todos app needs cloud infrastructure for deployment. This follows the
established pattern from email-unsubscribe and login apps: Cloud Run service with
Supabase database.

## What Changes

- Add Cloud Run service for todos app at todos.mklv.tech
- Configure GitHub Actions workflow for CI/CD via github-meta

## Capabilities

### New Capabilities

- `todos-cloud-run`: Cloud Run service configuration for the todos app using the
  cloud-run-app module. Includes custom domain mapping, secrets, and Supabase
  database setup (handled by the module).

### Modified Capabilities

None.

## Impact

- New Terramate stack at `gcp/apps/todos/`
- DNS record for todos.mklv.tech in domains stack
- GitHub workflow added via github-meta
