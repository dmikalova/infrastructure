stack {
  name        = "keyforge-card-gallery Cloud Run"
  description = "Cloud Run service for the KeyForge card gallery (gallery.keyforge.cards)"
  id          = "gcp-apps-keyforge-card-gallery"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/apps/keyforge-cards",
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/github/dmikalova",
  ]
}
