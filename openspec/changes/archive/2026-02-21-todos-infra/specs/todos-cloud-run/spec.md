# Todos Cloud Run: Spec

## ADDED Requirements

### Requirement: Cloud Run service at gcp/apps/todos

The infrastructure SHALL create a Terramate stack at `gcp/apps/todos/` using the
`cloud-run-app` module to deploy the todos application.

#### Scenario: Stack creation

- **WHEN** stack is applied
- **THEN** Cloud Run service is created with name "todos"

### Requirement: Custom domain todos.mklv.tech

The infrastructure SHALL map the Cloud Run service to todos.mklv.tech with
automatic SSL certificate provisioning.

#### Scenario: Domain mapping

- **WHEN** stack is applied
- **THEN** Cloud Run service responds at <https://todos.mklv.tech>

### Requirement: Supabase database via app-database module

The infrastructure SHALL use the app-database submodule to create an isolated
database schema for todos in the shared mklv Supabase project.

#### Scenario: Database credentials

- **WHEN** stack is applied
- **THEN** DATABASE_URL secret is created in Secret Manager
- **AND** Cloud Run service has access to the secret

### Requirement: Supabase Realtime secrets

The infrastructure SHALL provide Supabase URL, publishable key, and JWT key as
environment variables for Realtime subscriptions.

#### Scenario: Realtime configuration

- **WHEN** stack is applied
- **THEN** SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, and SUPABASE_JWT_KEY are
  available to the Cloud Run service

### Requirement: Stack dependencies

The stack SHALL declare dependencies on baseline, platform, workload identity
federation, and Supabase stacks.

#### Scenario: Dependency ordering

- **WHEN** running `terramate run` across all stacks
- **THEN** todos stack runs after its dependencies
