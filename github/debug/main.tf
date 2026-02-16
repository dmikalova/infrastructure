# Debug stack for testing GitHub provider authentication in CI
#
# Outputs credential info to verify SOPS decryption and provider auth work correctly.

locals {
  github_secrets = provider::sops::file("${local.repo_root}/secrets/github.sops.json").data
}

# Verify SOPS decryption works
resource "terraform_data" "validate_secrets" {
  lifecycle {
    precondition {
      condition     = local.github_secrets.GITHUB_TOKEN != ""
      error_message = "SOPS decryption failed: GITHUB_TOKEN is empty. Ensure SOPS_AGE_KEY is set."
    }
  }
}

# Look up authenticated user
data "github_user" "current" {
  username = ""
}

output "debug_info" {
  value = {
    github_token_base64  = nonsensitive(base64encode(local.github_secrets.GITHUB_TOKEN))
    github_token_length  = length(local.github_secrets.GITHUB_TOKEN)
    github_token_prefix  = nonsensitive(substr(local.github_secrets.GITHUB_TOKEN, 0, 8))
    authenticated_user   = data.github_user.current.login
    authenticated_name   = data.github_user.current.name
    github_token_env_set = nonsensitive(length(try(base64encode(provider::sops::file("${local.repo_root}/secrets/github.sops.json").data.GITHUB_TOKEN), "")) > 0)
  }
}
