# Stack definition for dmikalova GitHub repositories
stack {
  name        = "dmikalova"
  description = "GitHub repositories for dmikalova"
  id          = "github-dmikalova"
  tags        = ["github", "sops"]

  after = ["/gcp/infra/baseline"]
}

globals {
  github_owner = "dmikalova"
}
