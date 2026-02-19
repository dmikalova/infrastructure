# 1. SOPS Secrets Setup

- [x] 1.1 Create secrets/supabase.sops.json with SUPABASE_ACCESS_TOKEN and
      organization_id
- [x] 1.2 Update AGENTS.md SOPS table to include supabase.sops.json

## 2. Supabase Terramate Configuration

- [x] 2.1 Create supabase/terramate.tm.hcl with GCS backend config
- [x] 2.2 Add Supabase provider generation (supabase/supabase ~> 1.7)
- [x] 2.3 Add Google and SOPS provider generation

## 3. Supabase Stack Implementation

- [x] 3.1 Create supabase/dmikalova/stack.tm.hcl with stack definition
- [x] 3.2 Create supabase/dmikalova/main.tf with random_password resource
- [x] 3.3 Add supabase_project resource with name, org_id, password, region
- [x] 3.4 Add supabase_settings resource for connection pooling config
- [x] 3.5 Add google_secret_manager_secret for supabase-admin-url
- [x] 3.6 Add google_secret_manager_secret_version with derived connection URL
- [x] 3.7 Run terramate generate in supabase/

## 4. App Database Module

- [x] 4.1 Create terraform/modules/app-database/variables.tf with app_name input
- [x] 4.2 Create terraform/modules/app-database/main.tf with admin URL data
      source
- [x] 4.3 Add postgresql_schema resource with underscore naming
- [x] 4.4 Add postgresql_role resource with random password
- [x] 4.5 Add postgresql_grant for schema permissions (CREATE, USAGE)
- [x] 4.6 Add postgresql_grant for table permissions (SELECT, INSERT, UPDATE,
      DELETE)
- [x] 4.7 Add google_secret_manager_secret for app-specific DATABASE_URL
- [x] 4.8 Add google_secret_manager_secret_version with pooled connection string
- [x] 4.9 Create terraform/modules/app-database/outputs.tf with secret_id output

## 5. Verification

- [x] 5.1 Run tofu init in supabase/dmikalova
- [ ] 5.2 Run tofu plan to verify Supabase project creation
- [ ] 5.3 Run tofu apply to create Supabase project and admin secret
- [ ] 5.4 Verify admin-url secret exists in GCP Secret Manager
