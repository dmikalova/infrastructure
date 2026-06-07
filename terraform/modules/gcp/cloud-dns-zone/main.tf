# Cloud DNS Managed Zone
#
# Creates a public DNS managed zone for a domain with DNSSEC enabled.

resource "google_dns_managed_zone" "main" {
  dns_name = "${var.domain}."
  name     = replace(var.domain, ".", "-")
  project  = var.gcp_project_id

  dnssec_config {
    state = "on"
  }
}
