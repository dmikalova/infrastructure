output "domain_urls" {
  description = "Custom domain URLs"
  value = concat(
    ["https://${local.app_name}.${local.primary_domain}"],
    [for d in local.additional_domains : "https://${local.app_name}.${d}"]
  )
}

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}
