# Tasks Cloud Run: Spec

## ADDED Requirements

### Requirement: Cloud Run service at gcp/apps/tasks

The infrastructure SHALL create a Terramate stack at `gcp/apps/tasks/` using the
`cloud-run-app` module to deploy the tasks application.

#### Scenario: Stack creation

- **WHEN** stack is applied
- **THEN** Cloud Run service is created with name "tasks"

### Requirement: Custom domain tasks.mklv.tech

The infrastructure SHALL map the Cloud Run service to tasks.mklv.tech with
automatic SSL certificate provisioning.

#### Scenario: Domain mapping

- **WHEN** stack is applied
- **THEN** Cloud Run service responds at <https://tasks.mklv.tech>

### Requirement: Supabase database via app-database module

The infrastructure SHALL use the app-database submodule to create an isolated
database schema for tasks in the shared mklv Supabase project.

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
- **THEN** tasks stack runs after its dependencies
