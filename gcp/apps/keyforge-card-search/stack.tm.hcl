stack {
  name        = "keyforge-card-search Cloud Run"
  description = "Cloud Run service for keyforge-card-search (search.keyforge.cards)"
  id          = "gcp-apps-keyforge-card-search"
  tags        = ["google", "google-beta"]

  after = [
    "/gcp/apps/keyforge-cards",
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/github/dmikalova",
  ]
}
