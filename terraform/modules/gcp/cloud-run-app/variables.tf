# Cloud Run App Module
#
# Creates a Cloud Run service with:
# - Service account
# - Database URL secret access
# - Optional extra environment secrets (created by module)
# - Public access
# - GitHub Actions deploy permission
# - GCS bucket for app storage
# - startup_cpu_boost for faster cold starts
# - warm label for centralized warming

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
  default     = ""
}

variable "domain" {
  description = "Parent domain for the app. When set, creates a domain mapping and DNS record. Use subdomain to customize the prefix, or set subdomain=\"\" for apex domain."
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain prefix for domain mapping. Defaults to app_name. Set to empty string for apex domain (e.g., mklv.tech instead of app.mklv.tech)."
  type        = string
  default     = null
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

# Storage Bucket

variable "bucket_lifecycle_rules" {
  description = "Lifecycle rules for GCS bucket. Each rule applies to objects with the specified prefix."
  type = list(object({
    prefix   = string # Object name prefix (e.g., 'traces/')
    age_days = number # Delete objects older than this many days
  }))
  default = []
}

# Warming

variable "warm" {
  description = "Whether to include this service in centralized warming (adds warm=true label)"
  type        = bool
  default     = true
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
    name     = string                   # Job name
    schedule = string                   # Cron expression
    path     = string                   # HTTP path to invoke
    method   = optional(string, "POST") # HTTP method
    body     = optional(string, "")     # Request body
    timezone = optional(string, "UTC")  # Timezone for schedule
  }))
  default = []
}
