stack {
  name        = "Namecheap Domains"
  description = "Domain registrations and NS delegation on Namecheap"
  id          = "namecheap-domains"
  tags        = ["manual", "namecheap", "sops"]

  after = ["/gcp/infra/domains"]
}
