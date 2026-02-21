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

variable "database_url_session_secret_id" {
  description = "Secret Manager secret ID for DATABASE_URL_SESSION (session pooler, for CI migrations)"
  type        = string
  default     = ""
}

variable "database_url_transaction_secret_id" {
  description = "Secret Manager secret ID for DATABASE_URL_TRANSACTION (transaction pooler)"
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

variable "env_vars" {
  description = "Non-sensitive environment variables for Cloud Run container"
  type        = map(string)
  default     = {}
}

# Storage Buckets

variable "private_bucket" {
  description = "Create app-specific private GCS bucket for file storage"
  type        = bool
  default     = false
}

variable "private_bucket_lifecycle_rules" {
  description = "Lifecycle rules for private GCS bucket. Each rule applies to objects with the specified prefix."
  type = list(object({
    prefix   = string # Object name prefix (e.g., 'traces/')
    age_days = number # Delete objects older than this many days
  }))
  default = []
}

variable "public_bucket" {
  description = "Create app-specific public GCS bucket for static frontend assets"
  type        = bool
  default     = false
}

variable "ci_service_account" {
  description = "CI service account email for deploying frontend assets to public bucket"
  type        = string
  default     = ""
}

# Sidecars

variable "sidecars" {
  description = "Sidecar containers to run alongside the main app container. Sidecars communicate via localhost, not exposed ports."
  type = list(object({
    name    = string                    # Container name
    image   = string                    # Container image
    cpu     = optional(string, "1")     # CPU limit
    memory  = optional(string, "512Mi") # Memory limit
    command = optional(list(string))    # Container entrypoint
    args    = optional(list(string))    # Container arguments
    env     = optional(map(string), {}) # Environment variables
  }))
  default = []
}

# Scheduled Jobs

variable "scheduled_jobs" {
  description = "Cloud Scheduler jobs to invoke the Cloud Run service"
  type = list(object({
    name     = string                    # Job name
    schedule = string                    # Cron expression
    path     = string                    # HTTP path to invoke
    method   = optional(string, "POST")  # HTTP method
    body     = optional(string, "")      # Request body
    timezone = optional(string, "UTC")   # Timezone for schedule
  }))
  default = []
}
