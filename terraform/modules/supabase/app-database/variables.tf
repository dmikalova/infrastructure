# Variables for app-database module

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "supabase_project_ref" {
  description = "Supabase project reference ID (for connection URL construction)"
  type        = string
}

variable "supabase_region" {
  description = "Supabase project region (for pooler hostname construction)"
  type        = string
}
