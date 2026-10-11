# Cloud Run App Module
#
# Creates a Cloud Run service with:
# - Service account with Secret Manager access
# - App secrets stored as JSON, mounted at /secrets/config.json
# - Public access
# - GitHub Actions deploy permission
# - GCS bucket for app storage
# - startup_cpu_boost for faster cold starts
# - warm label for centralized warming

variable "app_name" {
  description = "Application name (used for service and service account naming)"
  type        = string
}

variable "bucket_lifecycle_rules" {
  description = "Lifecycle rules for GCS bucket. Each rule applies to objects with the specified prefix."
  type = list(object({
    prefix   = string # Object name prefix (e.g., 'traces/')
    age_days = number # Delete objects older than this many days
  }))
  default = []
}

variable "domain" {
  description = "Parent domain for the app. When set, creates a domain mapping and DNS record. Use subdomain to customize the prefix, or set subdomain=\"\" for apex domain."
  type        = string
  default     = ""
}

variable "env_vars" {
  description = "Non-sensitive environment variables for Cloud Run container"
  type        = map(string)
  default     = {}
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for Cloud Run"
  type        = string
}

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

variable "secrets" {
  description = "All secrets for this app as a map of env_name to value. Stored as one JSON Secret Manager secret and mounted at /secrets/config.json."
  type        = map(string)
  default     = {}
  sensitive   = true
}

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

variable "subdomain" {
  description = "Subdomain prefix for domain mapping. Defaults to app_name. Set to empty string for apex domain (e.g., mklv.tech instead of app.mklv.tech)."
  type        = string
  default     = null
}

variable "warm" {
  description = "Whether to include this service in centralized warming (adds warm=true label)"
  type        = bool
  default     = true
}
