# Namecheap Domain
#
# Configures nameserver delegation to external DNS for a domain on Namecheap.

terraform {
  required_providers {
    namecheap = {
      source = "namecheap/namecheap"
    }
  }
}

resource "namecheap_domain_records" "main" {
  domain      = var.domain
  mode        = "OVERWRITE"
  nameservers = [for ns in var.nameservers : trimsuffix(ns, ".")]
}
