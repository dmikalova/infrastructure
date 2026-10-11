stack {
  name        = "Namecheap Domains"
  description = "Domain registrations and NS delegation on Namecheap"
  id          = "namecheap-domains"

  # manual: the Namecheap API only answers allowlisted source IPs, and a CI
  # runner's address is neither fixed nor known in advance.
  tags = ["manual", "namecheap", "sops"]

  after = ["/gcp/infra/domains"]
}
