variable "project_id" {
  description = "GCP project ID containing the Supabase secret"
  type        = string
}

variable "secret_name" {
  description = "Name of the Secret Manager secret containing Supabase config"
  type        = string
}
