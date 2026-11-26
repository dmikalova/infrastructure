stack {
  name        = "keyforge-cards Cloud Run"
  description = "Landing pages for keyforge.cards, its amasser/bingo subdomains, and the shared public bucket"
  id          = "gcp-apps-keyforge-cards"
  tags        = ["google", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
  ]
}
