# vex Cloud Run service
#
# Serves the Vex browser client (Go + WebAssembly) at vex.mklv.tech.
# subdomain defaults to app_name, so the module maps vex.mklv.tech and
# creates its CNAME in the mklv-tech managed zone. warm defaults to true, so the
# mklv warming service keeps it warm.

locals {
  app_name = "vex"
}

# Cloud Run

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = "mklv.tech"
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region
}
