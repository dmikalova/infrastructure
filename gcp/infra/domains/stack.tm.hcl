stack {
  name        = "GCP Domains"
  description = "Cloud DNS managed zones for all domains"
  id          = "gcp-infra-domains"
  tags        = ["google", "sops"]

  after = ["/gcp/infra/baseline"]
}
