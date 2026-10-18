# den.mklv.tech
#
# Unlike the other subdomains here, nothing is deployed. The records point at
# a machine in a cupboard, and the only things reaching them are on the
# tailnet. The name exists so that den's services have a real address with a
# real certificate instead of an IP and a browser warning.

locals {
  domain        = "den.mklv.tech"
  parent_domain = "mklv.tech"
  parent_zone   = replace(local.parent_domain, ".", "-")

  # One line per service. The certificate is a wildcard, so this list only
  # decides what resolves, not what is trusted.
  services = ["beszel"]
}

data "terraform_remote_state" "tailnet" {
  backend = "gcs"

  config = {
    bucket = local.state_bucket
    prefix = "tfstate/tailscale/tailnet"
  }
}

data "terraform_remote_state" "den_secrets" {
  backend = "gcs"

  config = {
    bucket = local.state_bucket
    prefix = "tfstate/den/secrets"
  }
}

# Its own zone rather than records in mklv.tech, because den writes to this
# zone itself to answer ACME challenges. A credential scoped to this zone can
# only break den's names; the same credential on the parent could take down
# every site in the estate.
module "zone" {
  source = "${local.modules_dir}/gcp/cloud-dns-zone"

  domain         = local.domain
  gcp_project_id = local.project_id
}

resource "google_dns_record_set" "delegation" {
  managed_zone = local.parent_zone
  name         = "${local.domain}."
  project      = local.project_id
  rrdatas      = module.zone.nameservers
  ttl          = 300
  type         = "NS"
}

# The parent has DNSSEC on, so a delegation without this breaks resolution
# rather than merely leaving the child unsigned: a validating resolver treats
# the unsigned gap as an attack.
resource "google_dns_record_set" "delegation_ds" {
  managed_zone = local.parent_zone
  name         = "${local.domain}."
  project      = local.project_id
  ttl          = 300
  type         = "DS"

  rrdatas = [
    for key in module.zone.ds_record :
    "${key.key_tag} ${key.algorithm} ${key.digest_type} ${key.digest}"
  ]
}

# Tailnet addresses, read rather than written down. A CNAME to den's MagicDNS
# name would be shorter and would not work: ts.net resolves only through
# Tailscale's own resolver, so a public recursor hands back nothing.
resource "google_dns_record_set" "den_v4" {
  managed_zone = module.zone.zone_name
  name         = "${local.domain}."
  project      = local.project_id
  rrdatas      = data.terraform_remote_state.tailnet.outputs.den_ipv4_addresses
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "den_v6" {
  managed_zone = module.zone.zone_name
  name         = "${local.domain}."
  project      = local.project_id
  rrdatas      = data.terraform_remote_state.tailnet.outputs.den_ipv6_addresses
  ttl          = 300
  type         = "AAAA"
}

resource "google_dns_record_set" "service_v4" {
  for_each = toset(local.services)

  managed_zone = module.zone.zone_name
  name         = "${each.value}.${local.domain}."
  project      = local.project_id
  rrdatas      = data.terraform_remote_state.tailnet.outputs.den_ipv4_addresses
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "service_v6" {
  for_each = toset(local.services)

  managed_zone = module.zone.zone_name
  name         = "${each.value}.${local.domain}."
  project      = local.project_id
  rrdatas      = data.terraform_remote_state.tailnet.outputs.den_ipv6_addresses
  ttl          = 300
  type         = "AAAA"
}

# Caddy on den answers the ACME DNS-01 challenge, which means writing a TXT
# record into this zone every renewal. Bound to the zone, not the project:
# roles/dns.admin at the project level is what ADR 0008 forbids a host from
# holding. Zone-scoped admin is still wider than the TXT records it needs,
# because Cloud DNS has no predefined role for record sets alone.
resource "google_dns_managed_zone_iam_member" "den_writes_challenges" {
  managed_zone = module.zone.zone_name
  member       = "serviceAccount:${data.terraform_remote_state.den_secrets.outputs.host_service_account_email}"
  project      = local.project_id
  role         = "roles/dns.admin"
}
