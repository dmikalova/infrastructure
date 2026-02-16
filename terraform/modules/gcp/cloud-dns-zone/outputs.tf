output "nameservers" {
  description = "Nameservers assigned to this managed zone"
  value       = google_dns_managed_zone.main.name_servers
}

output "zone_name" {
  description = "The name of the managed zone resource"
  value       = google_dns_managed_zone.main.name
}
