# Supabase Platform

## ADDED Requirements

## Requirement: Supabase project managed via Terraform

The system SHALL create and manage the Supabase project using the official
`supabase/supabase` Terraform provider.

### Scenario: Project creation

- **WHEN** the supabase/dmikalova stack is applied
- **THEN** a Supabase project is created with the configured name and region
- **AND** the project database password is randomly generated

### Scenario: Project configuration

- **WHEN** the project is created
- **THEN** connection pooling is enabled in transaction mode
- **AND** the region is set to us-west-1 (near Cloud Run)

## Requirement: Supabase credentials from SOPS

The system SHALL read Supabase API credentials from SOPS-encrypted secrets.

### Scenario: Provider authentication

- **WHEN** the Supabase provider initializes
- **THEN** it reads SUPABASE_ACCESS_TOKEN from secrets/supabase.sops.json
- **AND** it reads organization_id from the same file

## Requirement: Admin connection secret storage

The system SHALL store the Supabase admin connection URL in GCP Secret Manager
for use by the app-database module.

### Scenario: Admin URL secret derived from project

- **WHEN** the supabase project resource is created
- **THEN** the admin connection string is constructed from project outputs
- **AND** stored in a secret named "supabase-admin-url"

## Requirement: Terramate stack configuration

The supabase directory SHALL have Terramate configuration for GCS backend, SOPS,
and Supabase providers.

### Scenario: Stack generates correct providers

- **WHEN** terramate generate is run
- **THEN** the stack generates _backend.tf with GCS backend prefix
  "tfstate/supabase/dmikalova"
- **AND** the stack generates _providers.tf with google, sops, and supabase
  providers
