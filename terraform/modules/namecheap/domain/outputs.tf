output "domain_name" {
  description = "The managed domain name"
  value       = namecheap_domain_records.main.domain
}
