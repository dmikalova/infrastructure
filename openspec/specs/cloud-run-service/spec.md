## ADDED Requirements

### Requirement: Per-app Terramate stack

The system SHALL create a Terramate stack per Cloud Run service at `gcp/infra/apps/<app-name>/`.

#### Scenario: App stack created for email-unsubscribe

- **WHEN** setting up the email-unsubscribe Cloud Run service
- **THEN** a Terramate stack exists at `gcp/infra/apps/email-unsubscribe/`

#### Scenario: Stack manages service shape only

- **WHEN** the app stack is applied
- **THEN** it manages Cloud Run service configuration (CPU, memory, env vars, secrets)
- **AND** it does NOT manage the container image version

### Requirement: Placeholder image for initial deployment

The system SHALL use a placeholder container image that Terraform can deploy before any real app image exists.

#### Scenario: Placeholder passes health checks

- **WHEN** Terraform creates the Cloud Run service with placeholder image
- **THEN** the image `gcr.io/cloudrun/placeholder` is used
- **AND** the service passes health checks and enters running state

### Requirement: Image version ignored by Terraform

The system SHALL use `ignore_changes` lifecycle to prevent Terraform from managing the container image version.

#### Scenario: Image changes ignored after creation

- **WHEN** GitHub Actions deploys a new image version
- **AND** Terraform runs `plan` or `apply` afterwards
- **THEN** Terraform does NOT attempt to revert the image to the placeholder

#### Scenario: Revision changes ignored

- **WHEN** a new Cloud Run revision is created by GHA deploy
- **THEN** Terraform ignores changes to `template[0].revision`

### Requirement: Secrets referenced from Secret Manager

The system SHALL configure Cloud Run environment variables to reference secrets stored in Secret Manager.

#### Scenario: DATABASE_URL injected from secret

- **WHEN** the Cloud Run service starts
- **THEN** the `DATABASE_URL` environment variable is populated from Secret Manager
- **AND** the secret version used is `latest`

#### Scenario: Cloud Run service account can access secrets

- **WHEN** the Cloud Run service is created
- **THEN** its service account has `roles/secretmanager.secretAccessor` on referenced secrets

### Requirement: Database credentials created at deploy time

The system SHALL use the app-database module to create per-app database credentials with schema-scoped access.

#### Scenario: App-database module provisions credentials

- **WHEN** the app stack uses the app-database module
- **THEN** the module creates a PostgreSQL schema named after the app
- **AND** creates a role with credentials that can only access that schema
- **AND** stores the DATABASE_URL in Secret Manager as `<app-name>-database-url`

#### Scenario: Credentials are least-privilege

- **WHEN** app-database module creates database credentials
- **THEN** the role has SELECT, INSERT, UPDATE, DELETE on tables in its schema only
- **AND** the role cannot access other schemas or system tables

#### Scenario: Secret rotation via version update

- **WHEN** a secret value needs to be rotated
- **THEN** a new version is created in Secret Manager
- **AND** Cloud Run picks up the new value on next deployment (using `latest` version)

### Requirement: Deploy SA can deploy but not modify service

The deploy service account SHALL be able to deploy new revisions but NOT modify service configuration.

#### Scenario: Deploy SA can push new image

- **WHEN** a GitHub Actions workflow authenticates with the deploy SA
- **THEN** it can deploy a new container image revision to the Cloud Run service

#### Scenario: Deploy SA cannot modify service config

- **WHEN** attempting to change CPU, memory, or environment variables via deploy SA
- **THEN** the operation is denied due to insufficient permissions

#### Scenario: Deploy SA cannot modify IAM

- **WHEN** attempting to change Cloud Run service IAM via deploy SA
- **THEN** the operation is denied due to insufficient permissions
