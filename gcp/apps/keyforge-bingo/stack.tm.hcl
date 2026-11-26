stack {
  name        = "keyforge-bingo Cloud Run"
  description = "Cloud Run service and database for keyforge-bingo (bingo.keyforge.cards)"
  id          = "gcp-apps-keyforge-bingo"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/github/dmikalova",
    "/supabase/mklv",
  ]
}
