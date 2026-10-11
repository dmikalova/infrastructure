variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "secrets" {
  description = "Map of local name to secret_id to look up"
  type        = map(string)
}
