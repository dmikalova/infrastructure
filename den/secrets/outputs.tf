# Exported so den/dns can grant this account a role without minting a second
# identity. den already holds one key; a DNS-only account would be a second
# key on the same disk for no reduction in blast radius.

output "host_service_account_email" {
  description = "The identity den authenticates to GCP as"
  value       = google_service_account.den_host.email
}
