# 1. Prerequisites

- [x] 1.1 Install Terramate CLI (`brew install terramate` or equivalent)
- [x] 1.2 Create GCP project via Console (manual one-time step)
- [x] 1.3 Note billing account ID for OpenTofu configuration
- [x] 1.4 Authenticate with GCP (`gcloud auth application-default login`)

## 2. Terramate Root Configuration

- [x] 2.1 Create `gcp/` directory structure (`gcp/infra/baseline/`,
      `gcp/project/`)
- [x] 2.2 Create `gcp/terramate.tm.hcl` with root configuration
- [x] 2.3 Define globals: `project_id`, `region`, `fabric_version`,
      `billing_account_id`
- [x] 2.4 Add code generation block for GCS backend (`_backend.tf`)
- [x] 2.5 Add code generation block for Google provider (`_providers.tf`)

## 3. Baseline Stack Setup

- [x] 3.1 Create `gcp/infra/baseline/stack.tm.hcl` with stack configuration
- [x] 3.2 Create `gcp/infra/baseline/main.tf` with Fabric `project` module
- [x] 3.3 Configure required APIs (Cloud Run, Artifact Registry, Secret Manager,
      IAM, Cloud Billing)
- [x] 3.4 Disable default Compute Engine service account in project module
- [x] 3.5 Add Fabric `iam-service-account` module for CI/CD service account
- [x] 3.6 Configure service account roles (Cloud Run Admin, Artifact Registry
      Writer, Secret Manager Accessor)

## 4. State Bucket and Budget

- [x] 4.1 Add Fabric `gcs` module for OpenTofu state bucket
- [x] 4.2 Enable versioning and set `prevent_destroy = true` lifecycle
- [x] 4.3 Add Fabric `billing-account` module for budget alerts
- [x] 4.4 Configure budget thresholds (50%, 80%, 100%) and email notification
- [x] 4.5 Create `variables.tf` with budget amount variable (default: $10)

## 5. Bootstrap with Local State

- [x] 5.1 Run `terramate generate` to create backend and provider files
- [x] 5.2 Comment out GCS backend temporarily for local state bootstrap
- [x] 5.3 Run `tofu init` in `gcp/infra/baseline/`
- [x] 5.4 Run `tofu apply` to create state bucket and resources
- [x] 5.5 Verify APIs enabled and Compute SA disabled in GCP Console

## 6. Migrate to Remote State

- [x] 6.1 Uncomment GCS backend configuration in generated files
- [x] 6.2 Run `tofu init -migrate-state` to move state to GCS
- [x] 6.3 Confirm state file exists in GCS bucket
- [x] 6.4 Run `tofu plan` to verify no drift after migration

## 7. Service Account Authentication

_Changed approach: Using service account impersonation instead of JSON keys for
better security._

- [x] 7.1 Configure `impersonate_service_account` in Google provider
- [x] 7.2 Grant `roles/iam.serviceAccountTokenCreator` to owner via SOPS email
- [x] 7.3 Grant `roles/billing.costsManager` at billing account level for budget
      management
- [x] 7.4 Verify impersonation works with `tofu plan`

## 8. Validation

- [x] 8.1 Run `terramate list` and verify baseline stack appears
- [x] 8.2 Run `terramate run -- tofu plan` and verify no changes
- [x] 8.3 Verify budget alerts configured in GCP Console
- [x] 8.4 Test service account permissions with a dry-run Cloud Run deploy
- [x] 8.5 Confirm Terragrunt commands in `digitalocean/` still work
