stack {
  name        = "todos Cloud Run"
  description = "Cloud Run service and database for todos app"
  id          = "gcp-apps-todos"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/supabase/mklv",
  ]
}
