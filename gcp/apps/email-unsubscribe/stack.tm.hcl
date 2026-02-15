stack {
  name        = "email-unsubscribe Cloud Run"
  description = "Cloud Run service and database for email-unsubscribe app"
  id          = "gcp-apps-email-unsubscribe"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/workload-identity-federation",
    "/supabase/mklv",
  ]
}
