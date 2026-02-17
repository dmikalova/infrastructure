stack {
  name        = "login Cloud Run"
  description = "Cloud Run service for multi-domain login portal"
  id          = "gcp-apps-login"
  tags        = ["google", "google-beta", "postgresql", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/domains",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
    "/supabase/mklv",
  ]
}
