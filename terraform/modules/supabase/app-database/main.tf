# App-specific database schema and credentials module
#
# Creates an isolated PostgreSQL schema with dedicated role and credentials.
# Outputs connection URLs for the calling stack to include in its app config secret.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  schema_name = replace(var.app_name, "-", "_")
  role_name   = "${var.app_name}-role"
}

resource "random_password" "db_password" {
  length  = 32
  special = false
}

# Create schema for this app
resource "postgresql_schema" "app" {
  name  = local.schema_name
  owner = postgresql_role.app.name
}

# Create role with login for this app
resource "postgresql_role" "app" {
  login    = true
  name     = local.role_name
  password = random_password.db_password.result
}

# Grant schema permissions (CREATE, USAGE)
resource "postgresql_grant" "schema" {
  database    = "postgres"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
  role        = postgresql_role.app.name
  schema      = local.schema_name

  depends_on = [postgresql_schema.app]
}

# Grant table permissions (SELECT, INSERT, UPDATE, DELETE)
resource "postgresql_grant" "tables" {
  database    = "postgres"
  object_type = "table"
  privileges  = ["DELETE", "INSERT", "SELECT", "UPDATE"]
  role        = postgresql_role.app.name
  schema      = local.schema_name

  depends_on = [postgresql_schema.app]
}
