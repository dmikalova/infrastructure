stack {
  name        = "tasks Cloud Run"
  description = "Cloud Run service and database for tasks app"
  id          = "gcp-apps-tasks"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/supabase/mklv",
  ]
}
