# App Database Module

## ADDED Requirements

## Requirement: Schema creation per app

The module SHALL create a PostgreSQL schema for each app, named using the app
name with hyphens converted to underscores.

### Scenario: Schema naming convention

- **WHEN** the module is called with app_name = "email-unsubscribe"
- **THEN** a schema named "email_unsubscribe" is created

## Requirement: Role-based isolation

The module SHALL create a PostgreSQL role for each app with login capability and
a randomly generated password.

### Scenario: Role creation

- **WHEN** the module is applied
- **THEN** a role named "{app_name}_role" is created
- **AND** the role has login capability
- **AND** the role password is randomly generated

## Requirement: Schema-scoped permissions

The module SHALL grant the app role permissions ONLY to its own schema,
providing true database-level isolation.

### Scenario: Permission grants

- **WHEN** the module creates an app role
- **THEN** the role has CREATE and USAGE on its schema
- **AND** the role has SELECT, INSERT, UPDATE, DELETE on tables in its schema
- **AND** the role cannot access other schemas

### Scenario: Cross-schema isolation

- **WHEN** an app connects with its role
- **THEN** queries to other apps' schemas fail with permission denied

## Requirement: App-specific secret creation

The module SHALL create a GCP Secret Manager secret containing the app-specific
DATABASE_URL with connection pooling enabled.

### Scenario: Secret creation

- **WHEN** the module is applied for app "email-unsubscribe"
- **THEN** a secret named "email-unsubscribe-database-url" is created
- **AND** the secret contains a pooled connection string with search_path set to
  the app schema

## Requirement: Admin URL from Secret Manager

The module SHALL read the Supabase admin connection URL from Secret Manager to
perform schema and role operations.

### Scenario: Admin credential retrieval

- **WHEN** the PostgreSQL provider needs to connect
- **THEN** it reads credentials from the "supabase-admin-url" secret

## Requirement: Module outputs

The module SHALL output the secret ID for use by Cloud Run service definitions.

### Scenario: Output for Cloud Run integration

- **WHEN** the module is applied
- **THEN** it outputs secret_id for the database URL secret
- **AND** the calling stack can reference this in Cloud Run env configuration
