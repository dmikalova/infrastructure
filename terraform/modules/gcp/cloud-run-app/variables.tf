# Cloud Run App Module
#
# Creates a Cloud Run service with:
# - Service account
# - Database URL secret access
# - Optional extra environment secrets (created by module)
# - Public access
# - GitHub Actions deploy permission

variable "app_name" {
  description = "Application name (used for service and service account naming)"
  type        = string
}

variable "database_secret_id" {
  description = "Secret Manager secret ID containing DATABASE_URL"
  type        = string
}

variable "domain" {
  description = "Parent domain for the app. When set, creates a domain mapping at <app_name>.<domain> and a CNAME record."
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for Cloud Run"
  type        = string
}

variable "modules_dir" {
  description = "Path to terraform/modules directory"
  type        = string
}

variable "secrets" {
  description = "Secrets to create in Secret Manager and expose as env vars. Key is the secret name in Secret Manager."
  type = map(object({
    env_name = string # Environment variable name in Cloud Run
    value    = string # Secret value to store
  }))
  default = {}
}

variable "existing_secrets" {
  description = "Existing secrets to expose as env vars (grants access, does not create). Key is the secret ID in Secret Manager."
  type = map(object({
    env_name = string # Environment variable name in Cloud Run
  }))
  default = {}
}
