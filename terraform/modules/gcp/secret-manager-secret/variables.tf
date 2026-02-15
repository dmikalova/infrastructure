variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "secrets" {
  description = "Map of secret_id to secret_data. Values are automatically treated as sensitive."
  type        = map(string)
}
