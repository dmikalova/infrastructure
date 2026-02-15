stack {
  name        = "Workload Identity Federation"
  description = "GitHub Actions WIF for keyless GCP authentication"
  id          = "gcp-infra-wif"
  tags        = ["google", "google-beta", "sops"]

  after = [
    "/gcp/infra/baseline",
    "/github/dmikalova",
  ]
}
