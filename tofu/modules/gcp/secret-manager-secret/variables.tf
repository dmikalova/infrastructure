variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "secrets" {
  description = "Map of secret_id to secret_data. Values are automatically treated as sensitive."
  type        = map(string)
}

# GCP rejects anything under 24h.
variable "version_destroy_ttl" {
  description = "How long a superseded secret version stays restorable before it is destroyed."
  type        = string
  default     = "2592000s" # 30 days
}
