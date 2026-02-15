stack {
  name        = "GCP Platform"
  description = "Shared app infrastructure: container registry, domains"
  id          = "gcp-infra-platform"
  tags        = ["google", "sops"]

  after = ["/gcp/infra/baseline"]
}
