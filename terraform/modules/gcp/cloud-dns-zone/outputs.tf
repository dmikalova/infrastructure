output "ds_record" {
  description = "DS record details per key for registrar DNSSEC setup (key tag, algorithm, digest type, digest)"
  value = {
    for key in data.google_dns_keys.main.key_signing_keys : key.id => {
      key_tag     = split(" ", key.ds_record)[0]
      algorithm   = split(" ", key.ds_record)[1]
      digest_type = split(" ", key.ds_record)[2]
      digest      = split(" ", key.ds_record)[3]
    }
  }
}

output "nameservers" {
  description = "Nameservers assigned to this managed zone"
  value       = google_dns_managed_zone.main.name_servers
}

output "zone_name" {
  description = "The name of the managed zone resource"
  value       = google_dns_managed_zone.main.name
}
