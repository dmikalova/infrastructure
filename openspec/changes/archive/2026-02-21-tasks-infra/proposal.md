# Tasks Infra: Proposal

## Why

The tasks app needs cloud infrastructure for deployment. This follows the
established pattern from email-unsubscribe and login apps: Cloud Run service with
Supabase database.

## What Changes

- Add Cloud Run service for tasks app at tasks.mklv.tech
- Configure GitHub Actions workflow for CI/CD via github-meta

## Capabilities

### New Capabilities

- `tasks-cloud-run`: Cloud Run service configuration for the tasks app using the
  cloud-run-app module. Includes custom domain mapping, secrets, and Supabase
  database setup (handled by the module).

### Modified Capabilities

None.

## Impact

- New Terramate stack at `gcp/apps/tasks/`
- DNS record for tasks.mklv.tech in domains stack
- GitHub workflow added via github-meta
