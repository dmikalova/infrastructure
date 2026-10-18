stack {
  name        = "den DNS"
  description = "den.mklv.tech as a delegated zone, den's tailnet records, and the credential Caddy renews certificates with"
  id          = "den-dns"
  tags        = ["den", "google"]

  # The parent zone must exist to be delegated from, den must be enrolled
  # before its addresses can be read, and the host account must exist before
  # it can be granted the zone.
  after = [
    "/den/secrets",
    "/gcp/infra/domains",
    "/tailscale/tailnet",
  ]
}
