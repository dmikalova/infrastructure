# GCP Baseline Configuration
# Creates: project APIs, CI/CD service account, state bucket, budget alerts

locals {
  # APIs to enable
  required_apis = [
    "artifactregistry.googleapis.com", # Artifact Registry
    "billingbudgets.googleapis.com",   # Billing Budgets API
    "cloudbilling.googleapis.com",     # Cloud Billing (for budgets)
    "iam.googleapis.com",              # IAM
    "run.googleapis.com",              # Cloud Run
    "secretmanager.googleapis.com",    # Secret Manager
  ]

  # Service account roles for CI/CD
  ci_roles = [
    "roles/artifactregistry.writer",      # Artifact Registry Writer
    "roles/run.admin",                    # Cloud Run Admin
    "roles/secretmanager.secretAccessor", # Secret Manager Accessor
  ]
}

# Enable required APIs on the project
# Note: The project itself is created manually via Console
# This just enables APIs on the existing project
resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

# Disable the default Compute Engine service account
# Security hardening - we're not using VMs
resource "google_project_default_service_accounts" "disable_compute_sa" {
  project = var.project_id
  action  = "DISABLE"
}

# CI/CD Service Account using Fabric module
module "ci_service_account" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v52.0.0"

  project_id = var.project_id
  name       = var.ci_service_account_name

  # Grant roles on the project
  iam_project_roles = {
    (var.project_id) = local.ci_roles
  }
}

# Terraform state bucket using Fabric module
module "state_bucket" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v52.0.0"

  project_id = var.project_id
  name       = var.state_bucket_name
  location   = var.region

  versioning = true

  # Lifecycle rule to prevent accidental deletion
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
resource "google_billing_budget" "monthly" {
  billing_account = var.billing_account
  display_name    = "${var.project_id}-monthly-budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = []
    disable_default_iam_recipients   = false
  }
}

# Prevent destruction of state bucket
resource "terraform_data" "prevent_state_bucket_destroy" {
  lifecycle {
    prevent_destroy = true
  }

  input = module.state_bucket.name
}
