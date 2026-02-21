output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.app.uri
}

output "service_account_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.cloud_run.email
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.app.name
}

output "private_bucket_name" {
  description = "Private GCS bucket name (empty if not enabled)"
  value       = var.private_bucket ? google_storage_bucket.private[0].name : ""
}

output "public_bucket_name" {
  description = "Public GCS bucket name (empty if not enabled)"
  value       = var.public_bucket ? google_storage_bucket.public[0].name : ""
}

output "public_bucket_url" {
  description = "Public GCS bucket URL for static assets (empty if not enabled)"
  value       = var.public_bucket ? "https://storage.googleapis.com/${google_storage_bucket.public[0].name}" : ""
}
