output "dnssec" {
  description = "DS record details per domain for registrar DNSSEC setup"
  value       = { for domain, zone in module.dns_zones : domain => zone.ds_record }
}

output "nameservers" {
  description = "Nameservers per domain"
  value       = { for domain, zone in module.dns_zones : domain => zone.nameservers }
}

output "zone_names" {
  description = "Zone names per domain"
  value       = { for domain, zone in module.dns_zones : domain => zone.zone_name }
}
