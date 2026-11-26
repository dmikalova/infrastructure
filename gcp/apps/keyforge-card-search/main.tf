# keyforge-card-search Cloud Run service
#
# The KeyForge card search at search.keyforge.cards. The service has no
# database and no secrets. It reads the card dataset from the public
# keyforge-cards bucket and reloads it when the dataset changes, so a new
# dataset does not need a deploy.

locals {
  app_name = "keyforge-card-search"
  domain   = "keyforge.cards"
}

# Cloud Run
#
# The module maps search.keyforge.cards and creates its CNAME in the
# keyforge-cards managed zone.

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  subdomain      = "search"
  domain         = local.domain
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  env_vars = {
    DATASET_URL = "https://storage.googleapis.com/mklv-keyforge-cards-public/data/cards.json"
  }
}
