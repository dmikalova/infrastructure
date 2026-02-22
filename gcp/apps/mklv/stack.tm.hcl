stack {
  name        = "mklv Cloud Run"
  description = "Warming service and landing page for mklv.tech"
  id          = "gcp-apps-mklv"
  tags        = ["google", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/platform",
    "/gcp/infra/workload-identity-federation",
  ]
}
