# GCP Baseline Configuration
# Creates: project, APIs, CI/CD service account, state bucket, budget alerts

locals {
  billing_account_id = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data.BILLING_ACCOUNT_ID
  owner_email        = provider::sops::file("${local.repo_root}/secrets/dmikalova.sops.json").data.email
}

# GCP Project - import existing project with: tofu import google_project.main <project-id>
resource "google_project" "main" {
  billing_account = local.billing_account_id
  name            = local.project_id
  project_id      = local.project_id

  lifecycle {
    prevent_destroy = true
  }
}

# Enable required APIs on the project
resource "google_project_service" "apis" {
  disable_on_destroy = false
  project            = google_project.main.project_id
  service            = each.value

  for_each = toset([
    "artifactregistry.googleapis.com", # Artifact Registry
    "billingbudgets.googleapis.com",   # Billing Budgets API
    "cloudbilling.googleapis.com",     # Cloud Billing (for budgets)
    "dns.googleapis.com",              # Cloud DNS
    "iam.googleapis.com",              # IAM
    "iamcredentials.googleapis.com",   # IAM Credentials (for WIF)
    "run.googleapis.com",              # Cloud Run
    "secretmanager.googleapis.com",    # Secret Manager
  ])
}

# Disable the default Compute Engine service account
# Security hardening - we're not using VMs
resource "google_project_default_service_accounts" "disable_compute_sa" {
  action  = "DISABLE"
  project = google_project.main.project_id
}

# CI/CD Service Account using Fabric module
module "ci_service_account" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v52.0.0"

  name       = "tofu-ci"
  project_id = google_project.main.project_id

  iam = {
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.owner_email}",
    ]
  }

  iam_project_roles = {
    (google_project.main.project_id) = [
      "roles/artifactregistry.admin",          # Artifact Registry Admin
      "roles/billing.projectManager",          # Manage project billing
      "roles/dns.admin",                       # Cloud DNS Admin
      "roles/iam.serviceAccountAdmin",         # Manage service accounts
      "roles/iam.serviceAccountUser",          # Act as service accounts (for Cloud Run)
      "roles/iam.workloadIdentityPoolAdmin",   # Manage WIF pools
      "roles/resourcemanager.projectIamAdmin", # Manage project IAM
      "roles/run.admin",                       # Cloud Run Admin
      "roles/secretmanager.admin",             # Secret Manager Admin
      "roles/serviceusage.serviceUsageAdmin",  # Enable/disable APIs
      "roles/storage.admin",                   # Manage GCS buckets
    ]
  }
}

# Grant billing budgets permission to CI service account
resource "google_billing_account_iam_member" "ci_budgets_admin" {
  billing_account_id = local.billing_account_id
  member             = module.ci_service_account.iam_email
  role               = "roles/billing.costsManager"
}

# OpenTofu state bucket using Fabric module
module "state_bucket" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v52.0.0"

  location   = local.gcp_region
  name       = "${google_project.main.project_id}-tfstate"
  project_id = google_project.main.project_id
  versioning = true

  lifecycle_rules = {
    prevent_old_versions = {
      action = {
        type = "Delete"
      }
      condition = {
        num_newer_versions = 5
        with_state         = "ARCHIVED"
      }
    }
  }
}

# Budget alerts
# Billing account budget (covers all projects under this billing account)
resource "google_billing_budget" "monthly" {
  billing_account = local.billing_account_id
  display_name    = "billing-account-monthly-budget"

  all_updates_rule {
    disable_default_iam_recipients   = false
    enable_project_level_recipients  = false
    monitoring_notification_channels = []
    schema_version                   = "1.0"
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "10" # USD per month
    }
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 0.5
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 0.8
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 1.0
  }

  # Workaround for https://github.com/hashicorp/terraform-provider-google/issues/8444
  lifecycle {
    ignore_changes = [all_updates_rule]
  }
}

# Prevent destruction of state bucket
resource "terraform_data" "prevent_state_bucket_destroy" {
  input = module.state_bucket.name

  lifecycle {
    prevent_destroy = true
  }
}
