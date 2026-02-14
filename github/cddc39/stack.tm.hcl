stack {
  id          = "github-cddc39"
  name        = "github-cddc39"
  description = "GitHub organization and repositories for cddc39"
  tags        = ["github", "sops"]

  after = ["/gcp/infra/baseline"]
}

globals {
  github_owner = "cddc39"
}
