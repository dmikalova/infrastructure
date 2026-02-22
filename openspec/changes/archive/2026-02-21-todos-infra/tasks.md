# Todos Infra: Tasks

## 1. Secrets Setup

- [x] 1.1 Check if SUPABASE_PUBLISHABLE_KEY exists in secrets/supabase.sops.json
- [x] 1.2 Add SUPABASE_PUBLISHABLE_KEY to SOPS file if missing (already exists)

## 2. Stack Creation

- [x] 2.1 Create gcp/apps/todos/ directory
- [x] 2.2 Create stack.tm.hcl with dependencies on baseline, platform, wif, and
      supabase
- [x] 2.3 Create \_terraform.tf (Terramate generated via `terramate generate`)
- [x] 2.4 Create main.tf using cloud-run-app module

## 3. Main Configuration

- [x] 3.1 Configure app_name = "todos"
- [x] 3.2 Configure domain = "mklv.tech" for todos.mklv.tech subdomain
- [x] 3.3 Add existing_secrets for SUPABASE_URL
- [x] 3.4 Add secrets block for SUPABASE_JWT_KEY and SUPABASE_PUBLISHABLE_KEY
      from supabase.sops.json

## 4. Validation

- [x] 4.1 Run tofu init in gcp/apps/todos/
- [x] 4.2 Run tofu plan and verify no errors
- [x] 4.3 Review plan output for expected resources (28 resources to add)

Note: Run `tofu apply` manually after PR review to deploy the infrastructure.
