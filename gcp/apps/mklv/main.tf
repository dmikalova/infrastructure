# mklv Cloud Run service
#
# Warming service and landing page for mklv.tech.
# Discovers other Cloud Run services with warm=true label and
# keeps them warm via health check pings.

locals {
  app_name = "mklv"
}

# Cloud Run Service

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = "mklv.tech"
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region
  modules_dir    = local.modules_dir

  # Don't warm ourselves (avoid self-warming loop)
  warm = false

  # Warming job runs every 10 minutes
  scheduled_jobs = [
    {
      name     = "warm"
      schedule = "*/10 * * * *"
      path     = "/api/warm"
      method   = "POST"
      timezone = "UTC"
    }
  ]
}

# IAM binding to allow Cloud Run service to list services

resource "google_project_iam_member" "run_viewer" {
  project = local.project_id
  role    = "roles/run.viewer"
  member  = "serviceAccount:${module.cloud_run.service_account_email}"
}
