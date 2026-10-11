data "google_project" "main" {
  project_id = local.project_id
}

data "terraform_remote_state" "github_dmikalova" {
  backend = "gcs"
  config = {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/github/dmikalova"
  }
}

locals {
  github_wif_pool = "projects/${data.google_project.main.number}/locations/global/workloadIdentityPools/github"

  # The account id behind the dmikalova login. Pinned rather than wildcarded
  # because a login can be released and re-registered by someone else, and an
  # id cannot. Hardcoded because the github stack's outputs carry full_name,
  # urls and topics, but no numeric id.
  github_owner_id = "324548"

  # Filter repos by mklv-tailscale topic
  ci_repos = {
    for name, repo in try(data.terraform_remote_state.github_dmikalova.outputs.repositories, {}) :
    name => repo if contains(try(repo.topics, []), "mklv-tailscale")
  }

  # Which repo may read each secret, keyed the same way the module keys them.
  ci_secret_owners = merge([
    for name, repo in local.ci_repos : {
      "tailscale-ci-${name}-audience"  = repo.full_name
      "tailscale-ci-${name}-client-id" = repo.full_name
    }
  ]...)
}

# Tags have no registry of their own: a tag exists only as a key in tagOwners,
# and the admin console will not offer a tag it cannot find here.
#
# Empty owner lists are deliberate. Tailscale treats every tag as implicitly
# owned by tailnet Owners and Admins, so naming an owner adds nothing.
resource "tailscale_acl" "tailnet" {
  # The live policy is still the default, so there is nothing to import and
  # nothing to lose. Revisit if the console ever becomes a second author.
  overwrite_existing_content = true

  acl = jsonencode({
    tagOwners = {
      "tag:ci"  = []
      "tag:den" = []
    }

    grants = [
      # CI reaches den over SSH only. The runner is ephemeral and joins for the
      # length of a job, so this is the whole of its reach.
      {
        src = ["tag:ci"]
        dst = ["tag:den"]
        ip  = ["22"]
      },
      {
        src = ["autogroup:member"]
        dst = ["tag:den"]
        ip  = ["*"]
      },
    ]

    # Tailscale SSH is authorized here, not by the port 22 grant above. The
    # grant lets the packets through; this permits the login.
    ssh = [
      {
        action = "accept"
        src    = ["tag:ci"]
        dst    = ["tag:den"]
        users  = ["root"]
      },
      # Without this nobody can log in at all, which is what den reports as a
      # health warning. "accept" rather than "check" so recovering den never
      # depends on reaching a browser to re-authenticate.
      {
        action = "accept"
        src    = ["autogroup:member"]
        dst    = ["tag:den"]
        users  = ["autogroup:nonroot", "root"]
      },
    ]

    # The policy file is validated at plan time, so a failing test blocks the
    # apply rather than locking us out after it.
    tests = [
      {
        src    = "tag:ci"
        accept = ["tag:den:22"]
        deny   = ["tag:den:80"]
      },
    ]
  })
}

# Adding a repo to the tailnet is a topic edit in the github stack and nothing
# else: it gets its own federated identity, its own pair of secrets, and read
# access to only those. Modelled on the mklv-deploy and infra-deploy filters.
resource "tailscale_federated_identity" "ci" {
  for_each = local.ci_repos

  description = "${each.key} CI"
  issuer      = "https://token.actions.githubusercontent.com"

  # GitHub issues immutable subjects, so the sub claim is not
  # repo:owner/name:... but repo:owner@ownerID/name@repoID:..., for example
  # repo:dmikalova@324548/den@1412746511:ref:refs/heads/main. A pattern built
  # from full_name alone never matches and the exchange returns 403.
  #
  # The owner id is pinned, so a login released and re-registered by someone
  # else cannot inherit this trust. The repo id stays a wildcard: this stack
  # does not have it, and a repo name can only be re-registered by whoever
  # already holds the pinned owner id.
  subject = format(
    "repo:%s@%s/%s@*:*",
    split("/", each.value.full_name)[0],
    local.github_owner_id,
    split("/", each.value.full_name)[1],
  )

  scopes = ["auth_keys"]
  tags   = ["tag:ci"]
}

# The console is the only place a rejected exchange explains itself, and the
# URL is just the client id. Printed here so nobody has to read it out of a
# failed job's logs.
output "tailscale_ci_trust_credentials" {
  description = "Admin console page for each CI federated identity"
  value = {
    for name, identity in tailscale_federated_identity.ci :
    name => "https://login.tailscale.com/admin/settings/trust-credentials/view/${identity.id}"
  }
}

# Neither value is a credential: a federated identity has no secret, and a
# token from the owning repo is required to use them. They live here so each
# repo has one way to read config, not because they need hiding.
module "ci" {
  source = "${local.modules_dir}/gcp/secret-manager-secret"

  project_id = local.project_id
  secrets = merge([
    for name, identity in tailscale_federated_identity.ci : {
      "tailscale-ci-${name}-audience"  = identity.audience
      "tailscale-ci-${name}-client-id" = identity.id
    }
  ]...)
}

# Granted to each repo's own federated identity rather than a service account,
# so no repo can impersonate its way to another's.
resource "google_secret_manager_secret_iam_member" "ci" {
  for_each = module.ci.secrets

  member    = "principalSet://iam.googleapis.com/${local.github_wif_pool}/attribute.repository/${local.ci_secret_owners[each.key]}"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.secret_id
}

# den authenticates to the tailnet with a key, not a token: tailscaled has no
# OIDC identity to present the way a CI runner does. Reusable so a rebuild does
# not need a new one, and recreated by Terraform once it expires.
#
# Deliberately not granted to the mklv-tailscale repos: this key enrols new
# machines as tag:den, which is a larger thing than reading a client ID.
resource "tailscale_tailnet_key" "den" {
  description         = "den host enrolment"
  ephemeral           = false
  preauthorized       = true
  recreate_if_invalid = "always"
  reusable            = true
  tags                = ["tag:den"]
}

module "gcp_secret_manager_secret" {
  source = "${local.modules_dir}/gcp/secret-manager-secret"

  project_id = local.project_id
  secrets = {
    "tailscale-den-authkey" = tailscale_tailnet_key.den.key
  }
}
