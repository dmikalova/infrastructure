variable "data" {
  description = "Map of key-value pairs to store as JSON in the secret"
  type        = map(string)
  sensitive   = true
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "secret_id" {
  description = "Secret Manager secret ID (e.g., 'tasks-config', 'supabase-mklv')"
  type        = string
}
