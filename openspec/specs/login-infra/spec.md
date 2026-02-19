# Login Infra

## ADDED Requirements

## Requirement: Cloud Run service deployed for login

The infrastructure SHALL deploy a Cloud Run service named `login` using the
existing `cloud-run-app` module pattern.

### Scenario: Service created with standard configuration

- **WHEN** the login stack is applied
- **THEN** a Cloud Run service named `login` is created with public access,
  service account, and CI/CD deploy permissions

## Requirement: Multiple domain mappings configured

The Cloud Run service SHALL have domain mappings for all supported login
domains.

### Prerequisite: Service account domain verification

Cloud Run domain mappings require the Terraform service account to be a verified
owner of each domain in Google Search Console. This is a one-time manual setup
per domain:

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Select the domain property (e.g., `keyforge.cards`)
3. Navigate to **Settings** → **Users and permissions**
4. Click **Add user**
5. Add: `tofu-ci@mklv-infrastructure.iam.gserviceaccount.com`
6. Set permission to **Owner**

If this step is missed, domain mapping creation will fail with: "Caller is not
authorized to administer the domain"

### Scenario: Domain mappings created

- **WHEN** the login stack is applied
- **THEN** domain mappings are created for login.mklv.tech, login.cddc39.tech,
  and login.keyforge.cards

### Scenario: DNS CNAME records created

- **WHEN** domain mappings are created
- **THEN** corresponding CNAME records pointing to ghs.googlehosted.com are
  created in each domain's Cloud DNS zone

## Requirement: Supabase app database provisioned

The infrastructure SHALL provision a dedicated database schema for the login
service using the `app-database` module.

### Scenario: Database schema created

- **WHEN** the login stack is applied
- **THEN** a PostgreSQL schema named `login` is created with a dedicated role

### Scenario: Database URL stored in Secret Manager

- **WHEN** the database is provisioned
- **THEN** the connection string is stored as `login-database-url` in Secret
  Manager

## Requirement: Login service has access to Supabase secrets

The login service Cloud Run SHALL have access to existing Supabase project
secrets.

### Scenario: Supabase URL accessible

- **WHEN** the login Cloud Run service starts
- **THEN** it can access `supabase-mklv-url` via its service account

### Scenario: Supabase anon key accessible

- **WHEN** the login Cloud Run service starts
- **THEN** it can access `supabase-mklv-anon-key` via its service account

## Requirement: App services have access to Supabase JWT secret

App services that verify JWTs SHALL have access to the Supabase JWT secret.

### Scenario: JWT secret accessible to email-unsubscribe

- **WHEN** the email-unsubscribe Cloud Run service starts
- **THEN** it can access `supabase-mklv-jwt-secret` via its service account

### Scenario: JWT secret accessible to login service

- **WHEN** the login Cloud Run service starts
- **THEN** it can access `supabase-mklv-jwt-secret` via its service account

## Requirement: GitHub repository created for login service

The infrastructure SHALL create a GitHub repository for the login service source
code.

### Scenario: Repository created

- **WHEN** the github/dmikalova stack is applied
- **THEN** a `login` repository is created with standard configuration (MIT
  license, Deno template)

### Scenario: CI/CD workflow configured

- **WHEN** the repository is created
- **THEN** it references the `deno-cloudrun.yaml` reusable workflow for
  deployment

## Requirement: Login stack declares dependencies

The login infrastructure stack SHALL declare its dependencies on prerequisite
stacks.

### Scenario: Stack dependencies defined

- **WHEN** the login stack is created
- **THEN** it declares `after` dependencies on `/gcp/infra/baseline`,
  `/gcp/infra/platform`, `/gcp/infra/domains`, and `/supabase/mklv`

## Requirement: PostgreSQL provider uses session pooler

The Terraform PostgreSQL provider SHALL use the Supabase session pooler for all
DDL operations.

### Background: Supabase connection modes

Supabase offers three connection types:

| Connection Type    | Port | IPv4 | Prepared Statements | Use Case                          |
| ------------------ | ---- | ---- | ------------------- | --------------------------------- |
| Direct             | 5432 | No   | Yes                 | Manual psql debugging only        |
| Session Pooler     | 5432 | Yes  | Yes                 | **Terraform DDL** (local + CI/CD) |
| Transaction Pooler | 6543 | Yes  | No                  | App runtime (serverless)          |

**Always use session pooler for Terraform.** It supports both IPv4 (required for
CI/CD) and prepared statements (required for PostgreSQL provider DDL
operations). The direct connection only works with IPv6 which most CI/CD
environments lack.

### Scenario: Session pooler used for Terraform

- **WHEN** the PostgreSQL provider is configured in app stacks
- **THEN** it uses `db-session-host` and `db-session-port` (5432)
- **AND** the same configuration works locally and in CI/CD
