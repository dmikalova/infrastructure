## 1. GitHub Stack Output Updates

- [x] 1.1 Add `deploy_access` variable to github/repositories module
- [x] 1.2 Add outputs.tf to github/repositories module with repo metadata map
- [x] 1.3 Update github/dmikalova main.tf to set deploy_access per repo
- [x] 1.4 Add outputs.tf to github/dmikalova stack exposing repo metadata

## 2. WIF Terramate Stack Setup

- [x] 2.1 Create gcp/infra/wif/stack.tm.hcl with stack definition
- [x] 2.2 Add stack dependency on github stacks via `after` attribute

## 3. WIF Pool and Provider

- [x] 3.1 Create google_iam_workload_identity_pool "github"
- [x] 3.2 Create google_iam_workload_identity_pool_provider "github-oidc" with attribute mapping

## 4. Service Accounts

- [x] 4.1 Create google_service_account "github-actions-infra" with broad permissions
- [x] 4.2 Create google_service_account "github-actions-deploy" with run.developer role
- [x] 4.3 Add IAM binding for infra SA restricted to dmikalova/infrastructure
- [x] 4.4 Add dynamic IAM bindings for deploy SA based on GitHub stack outputs

## 5. Cloud Run App Stack

- [x] 5.1 Create gcp/infra/apps/email-unsubscribe/stack.tm.hcl
- [x] 5.2 Add stack dependency on wif stack and supabase stack
- [x] 5.3 Use app-database module to create schema and DATABASE_URL secret
- [x] 5.4 Create google_cloud_run_v2_service with placeholder image
- [x] 5.5 Configure ignore_changes lifecycle for image and revision
- [x] 5.6 Add DATABASE_URL secret reference to Cloud Run env vars
- [x] 5.7 Grant Cloud Run service account secretmanager.secretAccessor on app secrets

## 6. Verification

- [x] 6.1 Run tofu init and plan in github/dmikalova
- [x] 6.2 Run tofu init and plan in gcp/infra/wif
- [x] 6.3 Run tofu init and plan in gcp/infra/apps/email-unsubscribe
