# Variables for supabase-project module

variable "gcp_project_id" {
  description = "GCP project ID for Secret Manager"
  type        = string
}

variable "name" {
  description = "Name of the Supabase project (used for project and secret naming)"
  type        = string
}

variable "organization_id" {
  description = "Supabase organization ID"
  type        = string
}

variable "region" {
  default     = "us-west-1"
  description = "Supabase region (e.g., us-west-1, us-west-2, us-east-1)"
  type        = string
}
