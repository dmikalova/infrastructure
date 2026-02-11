# Variables for GCP Baseline stack

variable "billing_account" {
  description = "GCP billing account ID"
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 10
}

variable "ci_service_account_name" {
  description = "Name for the CI/CD service account"
  type        = string
  default     = "terraform-ci"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Name for the Terraform state bucket"
  type        = string
}
