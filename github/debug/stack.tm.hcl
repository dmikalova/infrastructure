stack {
  id          = "github-debug"
  name        = "github-debug"
  description = "Debug stack for testing GitHub provider auth in CI"
  tags        = ["debug", "github", "sops"]

  after = ["/gcp/infra/baseline"]
}

globals {
  github_owner = "dmikalova"
}
