# keyforge-cards Cloud Run service
#
# Landing pages for keyforge.cards served from a single Cloud Run service.
# The app routes by request host to serve the apex site plus the amasser and
# bingo subdomains, so all three domains map to this one service.

locals {
  app_name   = "keyforge-cards"
  domain     = "keyforge.cards"
  subdomains = ["amasser", "bingo"]
}

# Cloud Run Service
#
# The module creates the apex (keyforge.cards) domain mapping and A/AAAA
# records. warm defaults to true, so the mklv warming service keeps it warm.

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = local.domain
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region
  subdomain      = "" # Deploy to apex domain (keyforge.cards)
}

# Subdomain Domain Mappings
#
# amasser.keyforge.cards and bingo.keyforge.cards map to the same service for
# host-based routing.

resource "google_cloud_run_domain_mapping" "subdomains" {
  for_each = toset(local.subdomains)

  location = local.gcp_region
  name     = "${each.value}.${local.domain}"
  project  = local.project_id

  metadata {
    namespace = local.project_id
  }

  spec {
    route_name = module.cloud_run.service_name
  }
}

resource "google_dns_record_set" "subdomains" {
  for_each = toset(local.subdomains)

  managed_zone = replace(local.domain, ".", "-")
  name         = "${each.value}.${local.domain}."
  project      = local.project_id
  rrdatas      = ["ghs.googlehosted.com."]
  ttl          = 300
  type         = "CNAME"
}
