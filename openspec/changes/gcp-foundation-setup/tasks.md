## 1. Prerequisites

- [ ] 1.1 Install Terramate CLI (`brew install terramate` or equivalent)
- [ ] 1.2 Create GCP project via Console (manual one-time step)
- [ ] 1.3 Note billing account ID for Terraform configuration
- [ ] 1.4 Authenticate with GCP (`gcloud auth application-default login`)

## 2. Terramate Root Configuration

- [ ] 2.1 Create `gcp/` directory structure (`gcp/infra/baseline/`, `gcp/project/`)
- [ ] 2.2 Create `gcp/terramate.tm.hcl` with root configuration
- [ ] 2.3 Define globals: `project_id`, `region`, `fabric_version`, `billing_account`
- [ ] 2.4 Add code generation block for GCS backend (`_backend.tf`)
- [ ] 2.5 Add code generation block for Google provider (`_providers.tf`)

## 3. Baseline Stack Setup

- [ ] 3.1 Create `gcp/infra/baseline/stack.tm.hcl` with stack configuration
- [ ] 3.2 Create `gcp/infra/baseline/main.tf` with Fabric `project` module
- [ ] 3.3 Configure required APIs (Cloud Run, Artifact Registry, Secret Manager, IAM, Cloud Billing)
- [ ] 3.4 Disable default Compute Engine service account in project module
- [ ] 3.5 Add Fabric `iam-service-account` module for CI/CD service account
- [ ] 3.6 Configure service account roles (Cloud Run Admin, Artifact Registry Writer, Secret Manager Accessor)

## 4. State Bucket and Budget

- [ ] 4.1 Add Fabric `gcs` module for Terraform state bucket
- [ ] 4.2 Enable versioning and set `prevent_destroy = true` lifecycle
- [ ] 4.3 Add Fabric `billing-account` module for budget alerts
- [ ] 4.4 Configure budget thresholds (50%, 80%, 100%) and email notification
- [ ] 4.5 Create `variables.tf` with budget amount variable (default: $10)

## 5. Bootstrap with Local State

- [ ] 5.1 Run `terramate generate` to create backend and provider files
- [ ] 5.2 Comment out GCS backend temporarily for local state bootstrap
- [ ] 5.3 Run `terraform init` in `gcp/infra/baseline/`
- [ ] 5.4 Run `terraform apply` to create state bucket and resources
- [ ] 5.5 Verify APIs enabled and Compute SA disabled in GCP Console

## 6. Migrate to Remote State

- [ ] 6.1 Uncomment GCS backend configuration in generated files
- [ ] 6.2 Run `terraform init -migrate-state` to move state to GCS
- [ ] 6.3 Confirm state file exists in GCS bucket
- [ ] 6.4 Run `terraform plan` to verify no drift after migration

## 7. Service Account Key

- [ ] 7.1 Generate JSON key for CI/CD service account via Console or gcloud
- [ ] 7.2 Create `secrets/gcp.sops.json` with encrypted key
- [ ] 7.3 Update SOPS configuration if needed for GCP key encryption
- [ ] 7.4 Verify key works with `gcloud auth activate-service-account`

## 8. Validation

- [ ] 8.1 Run `terramate list` and verify baseline stack appears
- [ ] 8.2 Run `terramate run -- terraform plan` and verify no changes
- [ ] 8.3 Verify budget alerts configured in GCP Console
- [ ] 8.4 Test service account permissions with a dry-run Cloud Run deploy
- [ ] 8.5 Confirm Terragrunt commands in `digitalocean/` still work
