# Cloud DNS Managed Zones
#
# Creates a Cloud DNS zone for each managed domain using the cloud-dns-zone module.
# Domain verification TXT records are added for Google Cloud Run domain mapping.

locals {
  domains = [
    "cddc39.tech",
    "dmikalova.dev",
    "keyforge.cards",
    "mklv.tech",
  ]
  gcp_secrets = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data

  # Map domain to SOPS key for Google verification tokens
  verification_tokens = {
    "keyforge.cards" = local.gcp_secrets.DNS_VERIFICATION_KEYFORGE_CARDS
    "mklv.tech"      = local.gcp_secrets.DNS_VERIFICATION_MKLV_TECH
  }
}

module "dns_zones" {
  source   = "${local.modules_dir}/gcp/cloud-dns-zone"
  for_each = toset(local.domains)

  domain         = each.value
  gcp_project_id = local.project_id
}

# Google domain verification TXT records for Cloud Run domain mapping
resource "google_dns_record_set" "verification" {
  for_each = local.verification_tokens

  managed_zone = module.dns_zones[each.key].zone_name
  name         = "${each.key}."
  project      = local.project_id
  rrdatas      = ["\"${each.value}\""]
  ttl          = 300
  type         = "TXT"
}

# Outputs

output "nameservers" {
  description = "Nameservers per domain"
  value       = { for domain, zone in module.dns_zones : domain => zone.nameservers }
}

output "zone_names" {
  description = "Zone names per domain"
  value       = { for domain, zone in module.dns_zones : domain => zone.zone_name }
}
