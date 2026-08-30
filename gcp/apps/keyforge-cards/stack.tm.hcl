stack {
  name        = "keyforge-cards Cloud Run"
  description = "Landing pages for keyforge.cards and its amasser/bingo subdomains"
  id          = "gcp-apps-keyforge-cards"
  tags        = ["google", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
  ]
}
