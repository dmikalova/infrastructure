output "bucket_name" {
  description = "GCS bucket name for app storage"
  value       = google_storage_bucket.bucket.name
}

output "public_bucket_name" {
  description = "Public GCS bucket name, or null when public_bucket_enabled is false"
  value       = var.public_bucket_enabled ? google_storage_bucket.public[0].name : null
}

output "public_bucket_url" {
  description = "Base URL of the public bucket's objects, or null when public_bucket_enabled is false"
  value       = var.public_bucket_enabled ? "https://storage.googleapis.com/${google_storage_bucket.public[0].name}" : null
}

output "service_account_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.cloud_run.email
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.app.name
}

output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.app.uri
}
