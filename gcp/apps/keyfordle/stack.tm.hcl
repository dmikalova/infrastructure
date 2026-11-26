stack {
  name        = "keyfordle Cloud Run"
  description = "Cloud Run service and database for keyfordle.keyforge.cards"
  id          = "gcp-apps-keyfordle"
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
