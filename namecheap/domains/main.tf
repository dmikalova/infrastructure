# Namecheap Domain Registrations
#
# Manages nameserver delegation to GCP Cloud DNS for all domains.
# Reads nameservers from the GCP domains stack via remote state.

data "terraform_remote_state" "gcp_domains" {
  backend = "gcs"

  config = {
    bucket = local.state_bucket
    prefix = "tfstate/gcp/infra/domains"
  }
}

module "domains" {
  source   = "${local.modules_dir}/namecheap/domain"
  for_each = data.terraform_remote_state.gcp_domains.outputs.nameservers

  domain      = each.key
  nameservers = each.value
}
