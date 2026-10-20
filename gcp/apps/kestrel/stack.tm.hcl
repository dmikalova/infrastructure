stack {
  name        = "kestrel Cloud Run"
  description = "Cloud Run service, database and check registry for kestrel"
  id          = "gcp-apps-kestrel"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/supabase/mklv",
  ]
}
