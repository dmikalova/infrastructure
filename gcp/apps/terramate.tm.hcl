# App stacks - Cloud Run deployment with Supabase database
# Stacks set local.app_name and local.supabase_project_name in main.tf
# Optional: local.extra_env_secrets map of env_name => secret_id for additional secrets

generate_hcl "_cloud_run_app.tf" {
  content {
    # -----------------------------------------------------------------------------
    # Database Setup
    # -----------------------------------------------------------------------------

    # Lookup Supabase database connection secrets
    module "db_secrets" {
      source = "${local.modules_dir}/gcp/secret-manager-secret-data"

      project_id = local.project_id
      secrets = {
        db_direct_host = "supabase-${local.supabase_project_name}-db-direct-host"
        db_direct_port = "supabase-${local.supabase_project_name}-db-direct-port"
        db_direct_user = "supabase-${local.supabase_project_name}-db-direct-user"
        db_name        = "supabase-${local.supabase_project_name}-db-name"
        db_password    = "supabase-${local.supabase_project_name}-db-password"
      }
    }

    # Configure postgresql provider with direct connection (not pooler)
    provider "postgresql" {
      connect_timeout = 15
      database        = module.db_secrets.secrets["db_name"].secret_data
      host            = module.db_secrets.secrets["db_direct_host"].secret_data
      password        = module.db_secrets.secrets["db_password"].secret_data
      port            = tonumber(module.db_secrets.secrets["db_direct_port"].secret_data)
      scheme          = "postgres"
      superuser       = false
      username        = module.db_secrets.secrets["db_direct_user"].secret_data
    }

    # Create app-specific database with credentials stored in Secret Manager
    module "app_database" {
      source = "${local.modules_dir}/supabase/app-database"

      app_name              = local.app_name
      gcp_project_id        = local.project_id
      modules_dir           = local.modules_dir
      supabase_project_name = local.supabase_project_name
    }

    # -----------------------------------------------------------------------------
    # Cloud Run Service
    # -----------------------------------------------------------------------------

    # Service account for Cloud Run
    resource "google_service_account" "cloud_run" {
      account_id   = "${local.app_name}-run"
      description  = "Cloud Run service account for ${local.app_name}"
      display_name = "${local.app_name} Cloud Run"
      project      = local.project_id
    }

    # Grant service account access to database secret
    resource "google_secret_manager_secret_iam_member" "database_url" {
      member    = "serviceAccount:${google_service_account.cloud_run.email}"
      project   = local.project_id
      role      = "roles/secretmanager.secretAccessor"
      secret_id = module.app_database.secret_id
    }

    # Cloud Run service (placeholder image, deployed via CI/CD)
    resource "google_cloud_run_v2_service" "app" {
      ingress  = "INGRESS_TRAFFIC_ALL"
      location = local.gcp_region
      name     = local.app_name
      project  = local.project_id

      template {
        service_account = google_service_account.cloud_run.email

        containers {
          image = "us-docker.pkg.dev/cloudrun/container/hello"

          env {
            name = "DATABASE_URL"
            value_source {
              secret_key_ref {
                secret  = module.app_database.secret_id
                version = "latest"
              }
            }
          }

          dynamic "env" {
            for_each = try(local.extra_env_secrets, {})
            content {
              name = env.key
              value_source {
                secret_key_ref {
                  secret  = env.value
                  version = "latest"
                }
              }
            }
          }

          resources {
            cpu_idle = true
            limits = {
              cpu    = "1"
              memory = "512Mi"
            }
          }
        }

        scaling {
          max_instance_count = 2
          min_instance_count = 0
        }
      }

      lifecycle {
        ignore_changes = [
          client,
          client_version,
          template[0].containers[0].image,
          template[0].revision,
        ]
      }
    }

    # Allow unauthenticated access
    resource "google_cloud_run_v2_service_iam_member" "public" {
      location = google_cloud_run_v2_service.app.location
      member   = "allUsers"
      name     = google_cloud_run_v2_service.app.name
      project  = local.project_id
      role     = "roles/run.invoker"
    }

    # -----------------------------------------------------------------------------
    # Outputs
    # -----------------------------------------------------------------------------

    output "service_url" {
      description = "Cloud Run service URL"
      value       = google_cloud_run_v2_service.app.uri
    }

    output "service_account_email" {
      description = "Cloud Run service account email"
      value       = google_service_account.cloud_run.email
    }
  }
}
