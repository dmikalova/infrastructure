## Why

Multiple apps (email-unsubscribe, lists, recipes, todos) need PostgreSQL databases. Supabase provides managed PostgreSQL with connection pooling, a generous free tier, and the ability to host multiple isolated schemas in a single project. Each app should have true database-level isolation via roles and permissions.

## What Changes

- Create single Supabase project (manual via dashboard)
- Store admin connection string in GCP Secret Manager (`supabase/` stack)
- Create reusable `terraform/modules/app-database/` module for per-app schema isolation
- Module creates: schema, database role with restricted permissions, app-specific DATABASE_URL secret
- Document pattern for adding new apps to the shared database

## Capabilities

### New Capabilities

- `supabase-platform`: Base Supabase project setup and admin credential storage. Located at `supabase/` directory.
- `app-database-module`: Reusable module for creating per-app database schemas with role-based isolation. Used by app deploy stacks in `gcp/projects/<app>/`.

### Modified Capabilities

None - no existing specs.

## Impact

- **External services**: New Supabase project (free tier, shared by all apps)
- **GCP resources**: Admin URL secret plus per-app DATABASE_URL secrets (created by app stacks)
- **App deployment**: Each app's infra calls the module to set up its schema and credentials
- **Development**: Local development can use same Supabase instance or local PostgreSQL
- **Scalability**: New apps call the module - no changes to base Supabase setup needed
