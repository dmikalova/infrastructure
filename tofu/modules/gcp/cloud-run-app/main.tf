# Secrets

resource "google_secret_manager_secret" "app_config" {
  count = length(var.secrets) > 0 ? 1 : 0

  project   = var.gcp_project_id
  secret_id = "${var.app_name}-config"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app_config" {
  count = length(var.secrets) > 0 ? 1 : 0

  secret      = google_secret_manager_secret.app_config[0].id
  secret_data = jsonencode(var.secrets)
}

# Service Account

resource "google_service_account" "cloud_run" {
  account_id   = "${var.app_name}-run"
  description  = "Cloud Run service account for ${var.app_name}"
  display_name = "${var.app_name} Cloud Run"
  project      = var.gcp_project_id
}

resource "google_secret_manager_secret_iam_member" "cloud_run_access" {
  count = length(var.secrets) > 0 ? 1 : 0

  project   = var.gcp_project_id
  secret_id = google_secret_manager_secret.app_config[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Storage Bucket

resource "google_storage_bucket" "bucket" {
  force_destroy               = false
  location                    = var.gcp_region
  name                        = "mklv-${var.app_name}"
  project                     = var.gcp_project_id
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  dynamic "lifecycle_rule" {
    for_each = var.bucket_lifecycle_rules
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

resource "google_storage_bucket_iam_member" "bucket_storage" {
  bucket = google_storage_bucket.bucket.name
  member = "serviceAccount:${google_service_account.cloud_run.email}"
  role   = "roles/storage.objectAdmin"
}

# Cloud Run Service

resource "google_cloud_run_v2_service" "app" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = var.gcp_region
  name     = var.app_name
  project  = var.gcp_project_id

  labels = {
    warm = tostring(var.warm)
  }

  template {
    service_account = google_service_account.cloud_run.email

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      env {
        name  = "BUCKET_NAME"
        value = google_storage_bucket.bucket.name
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "volume_mounts" {
        for_each = length(var.secrets) > 0 ? [1] : []
        content {
          name       = "app-config"
          mount_path = "/secrets"
        }
      }

      resources {
        cpu_idle          = true
        startup_cpu_boost = true
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
          cpu_idle          = true
          startup_cpu_boost = true
          limits = {
            cpu    = containers.value.cpu
            memory = containers.value.memory
          }
        }
      }
    }

    dynamic "volumes" {
      for_each = length(var.secrets) > 0 ? [1] : []
      content {
        name = "app-config"
        secret {
          secret = google_secret_manager_secret.app_config[0].secret_id
          items {
            version = "latest"
            path    = "config.json"
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
    google_secret_manager_secret_iam_member.cloud_run_access,
    google_secret_manager_secret_version.app_config,
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

resource "google_secret_manager_secret_iam_member" "deploy_access" {
  count = length(var.secrets) > 0 ? 1 : 0

  project   = var.gcp_project_id
  secret_id = google_secret_manager_secret.app_config[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:github-actions-deploy@${var.gcp_project_id}.iam.gserviceaccount.com"
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
  # subdomain defaults to app_name, set to "" for apex domain
  subdomain_prefix = var.subdomain != null ? var.subdomain : var.app_name
  custom_domain    = var.domain != "" ? (local.subdomain_prefix != "" ? "${local.subdomain_prefix}.${var.domain}" : var.domain) : ""
  dns_zone_name    = var.domain != "" ? replace(var.domain, ".", "-") : ""
  # Apex domains need A records, subdomains use CNAME
  is_apex_domain = local.subdomain_prefix == "" && var.domain != ""
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

# CNAME record for subdomain (conditional)
resource "google_dns_record_set" "custom_domain" {
  count = local.custom_domain != "" && !local.is_apex_domain ? 1 : 0

  managed_zone = local.dns_zone_name
  name         = "${local.custom_domain}."
  project      = var.gcp_project_id
  rrdatas      = ["ghs.googlehosted.com."]
  ttl          = 300
  type         = "CNAME"
}

# A records for apex domain (Cloud Run IPs)
resource "google_dns_record_set" "apex_domain" {
  count = local.is_apex_domain ? 1 : 0

  managed_zone = local.dns_zone_name
  name         = "${local.custom_domain}."
  project      = var.gcp_project_id
  # Cloud Run apex domain IPs (documented at https://cloud.google.com/run/docs/mapping-custom-domains#dns_update)
  rrdatas = ["216.239.32.21", "216.239.34.21", "216.239.36.21", "216.239.38.21"]
  ttl     = 300
  type    = "A"
}

# AAAA records for apex domain (Cloud Run IPv6)
resource "google_dns_record_set" "apex_domain_ipv6" {
  count = local.is_apex_domain ? 1 : 0

  managed_zone = local.dns_zone_name
  name         = "${local.custom_domain}."
  project      = var.gcp_project_id
  # Cloud Run apex domain IPv6 IPs
  rrdatas = ["2001:4860:4802:32::15", "2001:4860:4802:34::15", "2001:4860:4802:36::15", "2001:4860:4802:38::15"]
  ttl     = 300
  type    = "AAAA"
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
