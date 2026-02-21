# Secrets

# Extract non-sensitive keys for iteration
locals {
  existing_secret_names = toset(keys(var.existing_secrets))
  secret_names          = toset(keys(var.secrets))
}

# Create secrets in Secret Manager
# Key is the secret name, value.value is the secret data
module "secrets" {
  source = "${var.modules_dir}/gcp/secret-manager-secret"

  project_id = var.gcp_project_id
  secrets = {
    for secret_name in nonsensitive(local.secret_names) :
    secret_name => var.secrets[secret_name].value
  }
}

# Service Account

# Cloud Run service account
resource "google_service_account" "cloud_run" {
  account_id   = "${var.app_name}-run"
  description  = "Cloud Run service account for ${var.app_name}"
  display_name = "${var.app_name} Cloud Run"
  project      = var.gcp_project_id
}

# Grant service account access to database secret
resource "google_secret_manager_secret_iam_member" "database_url_transaction" {
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = var.database_url_transaction_secret_id
}

# Grant service account access to app secrets
resource "google_secret_manager_secret_iam_member" "secrets" {
  for_each = module.secrets.secrets

  member    = "serviceAccount:${google_service_account.cloud_run.email}"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.id
}

# Grant service account access to existing secrets
resource "google_secret_manager_secret_iam_member" "existing_secrets" {
  for_each = nonsensitive(local.existing_secret_names)

  member    = "serviceAccount:${google_service_account.cloud_run.email}"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value
}

# Private Storage Bucket (for app-specific data, not publicly accessible)

resource "google_storage_bucket" "private" {
  count = var.private_bucket ? 1 : 0

  force_destroy               = false
  location                    = var.gcp_region
  name                        = "mklv-${var.app_name}-private"
  project                     = var.gcp_project_id
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  dynamic "lifecycle_rule" {
    for_each = var.private_bucket_lifecycle_rules
    content {
      action {
        type = "Delete"
      }
      condition {
        age            = lifecycle_rule.value.age_days
        matches_prefix = [lifecycle_rule.value.prefix]
        with_state     = "ANY"
      }
    }
  }
}

resource "google_storage_bucket_iam_member" "private_storage" {
  count = var.private_bucket ? 1 : 0

  bucket = google_storage_bucket.private[0].name
  member = "serviceAccount:${google_service_account.cloud_run.email}"
  role   = "roles/storage.objectAdmin"
}

# Public Storage Bucket (for static frontend assets, publicly accessible)

resource "google_storage_bucket" "public" {
  count = var.public_bucket ? 1 : 0

  force_destroy               = false
  location                    = var.gcp_region
  name                        = "mklv-${var.app_name}-public"
  project                     = var.gcp_project_id
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 4
      with_state         = "ARCHIVED"
    }
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age        = 90
      with_state = "ARCHIVED"
    }
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Public bucket IAM: allUsers can read

resource "google_storage_bucket_iam_member" "public_all_users" {
  count = var.public_bucket ? 1 : 0

  bucket = google_storage_bucket.public[0].name
  member = "allUsers"
  role   = "roles/storage.objectViewer"
}

# Public bucket IAM: Cloud Run service account can write (for app-managed uploads)

resource "google_storage_bucket_iam_member" "public_app_write" {
  count = var.public_bucket ? 1 : 0

  bucket = google_storage_bucket.public[0].name
  member = "serviceAccount:${google_service_account.cloud_run.email}"
  role   = "roles/storage.objectAdmin"
}

# Public bucket IAM: CI service account can write (for deploying frontend assets)

resource "google_storage_bucket_iam_member" "public_ci_write" {
  count = var.public_bucket && var.ci_service_account != "" ? 1 : 0

  bucket = google_storage_bucket.public[0].name
  member = "serviceAccount:${var.ci_service_account}"
  role   = "roles/storage.objectAdmin"
}

# Cloud Run Service

# Cloud Run service (placeholder image, deployed via CI/CD)
resource "google_cloud_run_v2_service" "app" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = var.gcp_region
  name     = var.app_name
  project  = var.gcp_project_id

  template {
    service_account = google_service_account.cloud_run.email

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      env {
        name = "DATABASE_URL_TRANSACTION"
        value_source {
          secret_key_ref {
            secret  = var.database_url_transaction_secret_id
            version = "latest"
          }
        }
      }

      dynamic "env" {
        for_each = nonsensitive(local.secret_names)
        content {
          name = var.secrets[env.value].env_name
          value_source {
            secret_key_ref {
              secret  = module.secrets.secrets[env.value].secret_id
              version = "latest"
            }
          }
        }
      }

      dynamic "env" {
        for_each = nonsensitive(local.existing_secret_names)
        content {
          name = var.existing_secrets[env.value].env_name
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }

      dynamic "env" {
        for_each = var.private_bucket ? [1] : []
        content {
          name  = "PRIVATE_BUCKET_NAME"
          value = google_storage_bucket.private[0].name
        }
      }

      dynamic "env" {
        for_each = var.public_bucket ? [1] : []
        content {
          name  = "PUBLIC_BUCKET_NAME"
          value = google_storage_bucket.public[0].name
        }
      }

      dynamic "env" {
        for_each = var.public_bucket ? [1] : []
        content {
          name  = "PUBLIC_BUCKET_URL"
          value = "https://storage.googleapis.com/${google_storage_bucket.public[0].name}"
        }
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
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

    # Sidecar containers
    dynamic "containers" {
      for_each = var.sidecars
      content {
        name    = containers.value.name
        image   = containers.value.image
        command = containers.value.command
        args    = containers.value.args


        dynamic "env" {
          for_each = containers.value.env
          content {
            name  = env.key
            value = env.value
          }
        }

        resources {
          cpu_idle = true
          limits = {
            cpu    = containers.value.cpu
            memory = containers.value.memory
          }
        }
      }
    }

    scaling {
      max_instance_count = 2
      min_instance_count = 0
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_member.database_url_transaction,
    google_secret_manager_secret_iam_member.existing_secrets,
    google_secret_manager_secret_iam_member.secrets,
  ]

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
  project  = var.gcp_project_id
  role     = "roles/run.invoker"
}

# Allow GitHub Actions deploy SA to act as Cloud Run service account
resource "google_service_account_iam_member" "deploy_can_act_as" {
  member             = "serviceAccount:github-actions-deploy@${var.gcp_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  service_account_id = google_service_account.cloud_run.name
}

# Grant deploy SA access to database secret (required for Cloud Run deployment validation)
resource "google_secret_manager_secret_iam_member" "deploy_database_url_transaction" {
  member    = "serviceAccount:github-actions-deploy@${var.gcp_project_id}.iam.gserviceaccount.com"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = var.database_url_transaction_secret_id
}

# Grant deploy SA access to session database secret (required for CI migrations)
resource "google_secret_manager_secret_iam_member" "deploy_database_url_session" {
  count = var.database_url_session_secret_id != "" ? 1 : 0

  member    = "serviceAccount:github-actions-deploy@${var.gcp_project_id}.iam.gserviceaccount.com"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = var.database_url_session_secret_id
}

# Grant deploy SA access to app secrets (required for Cloud Run deployment validation)
resource "google_secret_manager_secret_iam_member" "deploy_secrets" {
  for_each = module.secrets.secrets

  member    = "serviceAccount:github-actions-deploy@${var.gcp_project_id}.iam.gserviceaccount.com"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.id
}

# Grant deploy SA access to existing secrets (required for Cloud Run deployment validation)
resource "google_secret_manager_secret_iam_member" "deploy_existing_secrets" {
  for_each = nonsensitive(local.existing_secret_names)

  member    = "serviceAccount:github-actions-deploy@${var.gcp_project_id}.iam.gserviceaccount.com"
  project   = var.gcp_project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value
}

# Custom Domain
#
# PREREQUISITE: The Terraform service account must be a verified owner of the domain
# in Google Search Console. Without this, domain mapping creation will fail with:
# "Caller is not authorized to administer the domain"
#
# To fix:
# 1. Go to https://search.google.com/search-console
# 2. Select the domain property (e.g., example.com)
# 3. Settings → Users and permissions → Add user
# 4. Add the service account email as Owner
#
# This is a one-time manual setup per domain.

locals {
  custom_domain = var.domain != "" ? "${var.app_name}.${var.domain}" : ""
  dns_zone_name = var.domain != "" ? replace(var.domain, ".", "-") : ""
}

# Domain mapping for custom domain (conditional)
resource "google_cloud_run_domain_mapping" "custom" {
  count = local.custom_domain != "" ? 1 : 0

  location = google_cloud_run_v2_service.app.location
  name     = local.custom_domain
  project  = var.gcp_project_id

  metadata {
    namespace = var.gcp_project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.app.name
  }
}

# CNAME record pointing custom domain to Google hosted services (conditional)
resource "google_dns_record_set" "custom_domain" {
  count = local.custom_domain != "" ? 1 : 0

  managed_zone = local.dns_zone_name
  name         = "${local.custom_domain}."
  project      = var.gcp_project_id
  rrdatas      = ["ghs.googlehosted.com."]
  ttl          = 300
  type         = "CNAME"
}

# Scheduled Jobs

resource "google_service_account" "scheduler" {
  count = length(var.scheduled_jobs) > 0 ? 1 : 0

  account_id   = "${var.app_name}-scheduler"
  description  = "Cloud Scheduler invoker for ${var.app_name}"
  display_name = "${var.app_name} Scheduler"
  project      = var.gcp_project_id
}

resource "google_cloud_run_v2_service_iam_member" "scheduler_invoker" {
  count = length(var.scheduled_jobs) > 0 ? 1 : 0

  location = google_cloud_run_v2_service.app.location
  member   = "serviceAccount:${google_service_account.scheduler[0].email}"
  name     = google_cloud_run_v2_service.app.name
  project  = var.gcp_project_id
  role     = "roles/run.invoker"
}

resource "google_cloud_scheduler_job" "jobs" {
  for_each = { for job in var.scheduled_jobs : job.name => job }

  attempt_deadline = "320s"
  name             = "${var.app_name}-${each.value.name}"
  project          = var.gcp_project_id
  region           = var.gcp_region
  schedule         = each.value.schedule
  time_zone        = each.value.timezone

  http_target {
    body        = base64encode(each.value.body)
    http_method = each.value.method
    uri         = "${google_cloud_run_v2_service.app.uri}${each.value.path}"

    oidc_token {
      audience              = google_cloud_run_v2_service.app.uri
      service_account_email = google_service_account.scheduler[0].email
    }
  }

  retry_config {
    max_backoff_duration = "3600s"
    max_doublings        = 5
    max_retry_duration   = "0s"
    min_backoff_duration = "5s"
    retry_count          = 0
  }
}
