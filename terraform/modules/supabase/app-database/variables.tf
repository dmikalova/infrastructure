# Variables for app-database module

variable "app_name" {
  description = "Name of the application (used for schema, role, and secret naming)"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID for Secret Manager"
  type        = string
}

variable "modules_dir" {
  description = "Path to terraform modules directory"
  type        = string
}

variable "supabase_project_name" {
  description = "Name of the Supabase project (used for secret naming)"
  type        = string
}
