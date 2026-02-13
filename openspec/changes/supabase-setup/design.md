## Context

The email-unsubscribe app requires PostgreSQL for:

- User accounts and OAuth tokens (encrypted)
- Email scan state and history
- Unsubscribe tracking and audit logs

Cloud Run is ephemeral and scales to zero, requiring:

- External database (not in-cluster)
- Connection pooling (Cloud Run creates many short-lived connections)
- Public endpoint (no VPC for simplicity)

## Goals / Non-Goals

**Goals:**

- Set up Supabase project as shared database platform
- Store admin connection string for schema management
- Create reusable module for per-app schema isolation
- True database-level isolation (roles/permissions, not just search_path)
- Support local development with same database or local PostgreSQL

**Non-Goals:**

- Using Supabase Auth (apps have custom auth flows)
- Using Supabase Realtime or Edge Functions
- Database backups beyond Supabase's default
- Per-app schema setup (handled by app deploy stacks)

## Decisions

### 1. Repository Structure

**Decision:** Supabase base setup at `supabase/`, app-specific schemas created by app deploy stacks.

```
infrastructure/
├── supabase/
│   ├── terramate.tm.hcl     # Supabase-specific config
│   └── dmikalova/
│       ├── stack.tm.hcl
│       └── main.tf          # Admin secrets only
├── terraform/
│   └── modules/
│       └── app-database/    # Reusable schema isolation module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
└── gcp/
    └── projects/
        └── email-unsubscribe/
            └── main.tf      # Uses app-database module
```

**Rationale:** Clear separation - `supabase/` manages the platform, app stacks manage their own database needs using a shared module.

### 2. Supabase Project Management

**Decision:** Create Supabase project manually via dashboard, manage connection string as secret.

**Alternatives considered:**

- Terraform Supabase provider: Provider exists but is community-maintained and limited
- Pulumi Supabase provider: Same limitations

**Rationale:** Supabase projects are rarely created/destroyed. Manual setup via dashboard is simpler and more reliable. The connection string is the only integration point needed.

### 2. Connection Pooling

**Decision:** Use Supabase's built-in PgBouncer pooler in transaction mode.

```
# Direct connection (for migrations):
postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# Pooled connection (for app):
postgresql://postgres.[project-ref]:[password]@aws-0-us-west-1.pooler.supabase.com:6543/postgres?pgbouncer=true
```

**Rationale:** Cloud Run creates new connections frequently. Transaction pooling handles this efficiently. Supabase's pooler is included free.

### 3. Secret Storage (Two Levels)

**Decision:** Admin credentials in `supabase/` stack, app-specific credentials created by app stacks.

```hcl
# supabase/dmikalova/main.tf - Admin connection (for schema management)
resource "google_secret_manager_secret" "supabase_admin_url" {
  secret_id = "supabase-admin-url"
  replication { auto {} }
}

# gcp/projects/email-unsubscribe/main.tf - App-specific connection
module "database" {
  source   = "../../../terraform/modules/app-database"
  app_name = "email-unsubscribe"
  # Creates schema, role, and app-specific secret
}
```

**Rationale:** Admin credentials have full access (needed for creating schemas/roles). App credentials are scoped to their schema only.

### 4. Schema Isolation Module (Multi-Tenant Design)

**Decision:** Reusable `terraform/modules/app-database/` module creates schema, role, and credentials per app.

```hcl
# terraform/modules/app-database/main.tf

# Read admin connection from Secret Manager
data "google_secret_manager_secret_version" "admin_url" {
  secret = "supabase-admin-url"
}

# Create schema for this app
resource "postgresql_schema" "app" {
  name  = replace(var.app_name, "-", "_")  # email_unsubscribe
  owner = postgresql_role.app.name
}

# Create role with permissions only to this schema
resource "postgresql_role" "app" {
  name     = "${var.app_name}_role"
  login    = true
  password = random_password.db_password.result
}

# Grant permissions only to app's schema
resource "postgresql_grant" "schema" {
  role        = postgresql_role.app.name
  schema      = postgresql_schema.app.name
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
}

resource "postgresql_grant" "tables" {
  role        = postgresql_role.app.name
  schema      = postgresql_schema.app.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

# Store app-specific connection string in Secret Manager
resource "google_secret_manager_secret" "database_url" {
  secret_id = "${var.app_name}-database-url"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${postgresql_role.app.name}:${random_password.db_password.result}@pooler.supabase.com:6543/postgres?options=-csearch_path%3D${postgresql_schema.app.name}"
}
```

**Usage in app stack:**

```hcl
# gcp/projects/email-unsubscribe/main.tf

module "database" {
  source   = "../../../terraform/modules/app-database"
  app_name = "email-unsubscribe"
}

resource "google_cloud_run_v2_service" "app" {
  # ...
  template {
    containers {
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = module.database.secret_id
            version = "latest"
          }
        }
      }
    }
  }
}
```

**Alternatives considered:**

- Shared admin credentials with search_path: No true isolation, app could access other schemas
- Separate databases per app: More isolation but higher cost and management overhead

**Rationale:** True database-level isolation via roles/permissions:

- Each app has its own PostgreSQL role
- Role can only access its own schema
- App can't see or modify other apps' tables
- Credentials are app-specific and stored separately

### 5. Migration Workflow

**Decision:** Database migrations run from the app repo, not infrastructure.

```bash
# In email-unsubscribe repo:
deno task db:migrate
```

**Rationale:** Migrations are app-specific and change with app code. Running from app repo keeps them versioned together. Infrastructure only provides the database, not its schema.

### 6. Local Development

**Decision:** Support both remote Supabase and local PostgreSQL.

```bash
# Option 1: Use remote Supabase (shared state)
export DATABASE_URL="postgresql://..."  # From Supabase dashboard

# Option 2: Local PostgreSQL (isolated)
docker run -d --name postgres -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres:16
export DATABASE_URL="postgresql://postgres:dev@localhost:5432/postgres"
```

**Rationale:** Remote is simpler for quick testing. Local is better for offline work or schema experiments. App code should work with either.

## Risks / Trade-offs

| Risk                                   | Mitigation                                                  |
| -------------------------------------- | ----------------------------------------------------------- |
| Supabase free tier limits              | Monitor usage, upgrade if needed (generous limits)          |
| Pooler connection limits               | Use transaction mode, close connections promptly            |
| PostgreSQL provider needs admin access | Admin URL stored securely, only used during schema creation |
| Role password in state                 | Use random_password, state is encrypted                     |

## Migration Plan

### This Change (supabase-setup)

1. **Create Supabase project** - Via dashboard, choose region near Cloud Run (us-west)
2. **Configure project** - Enable connection pooling, note admin connection string
3. **Create `supabase/` stack** - Store admin URL in Secret Manager
4. **Create `terraform/modules/app-database/`** - Reusable module for schema isolation

### Per-App (in gcp-github-wif change)

5. **App stacks use module** - `gcp/projects/<app>/` calls `app-database` module
6. **Module creates schema, role, credentials** - Automatically during app infra deploy
7. **Cloud Run references app secret** - App gets isolated database access

## Open Questions

None - straightforward setup.
