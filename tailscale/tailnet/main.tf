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

  # Filter repos by mklv-tailscale topic
  ci_repos = {
    for name, repo in try(data.terraform_remote_state.github_dmikalova.outputs.repositories, {}) :
    name => repo if contains(try(repo.topics, []), "mklv-tailscale")
  }

  # Which repo may read each secret, keyed the same way the module keys them.
  ci_secret_owners = {
    for name, repo in local.ci_repos : "tailscale-ci-${name}" => repo.full_name
  }
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

  subject = format(
    "repo:%s@%s/%s@%s:*",
    data.terraform_remote_state.github_dmikalova.outputs.owner,
    data.terraform_remote_state.github_dmikalova.outputs.owner_id,
    each.value.name,
    each.value.repo_id,
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
#
# One secret per repo rather than one per value, because the grant is per
# secret: a repo that reads its own config should make one call, not two.
module "ci" {
  source   = "${local.modules_dir}/gcp/secret-manager-project-secret"
  for_each = tailscale_federated_identity.ci

  project_id = local.project_id
  secret_id  = "tailscale-ci-${each.key}"
  data = {
    AUDIENCE  = each.value.audience
    CLIENT_ID = each.value.id
  }
}

# Granted to each repo's own federated identity rather than a service account,
# so no repo can impersonate its way to another's.
resource "google_secret_manager_secret_iam_member" "ci" {
  for_each = module.ci

  member    = "principalSet://iam.googleapis.com/${local.github_wif_pool}/attribute.repository/${local.ci_secret_owners[each.value.secret_id]}"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.secret_id
}

# den authenticates to the tailnet with an OAuth client, not a token:
# tailscaled has no OIDC identity to present the way a CI runner does. The
# client secret is itself an auth key and never expires, unlike a tailnet key,
# so a rebuild months from now still enrols.
#
# devices:core is what lets `den apply` delete the dead den node a reinstall
# leaves behind, so the new one enrols as den and not den-1. The tag bounds
# both scopes to tag:den devices.
#
# Deliberately not granted to the mklv-tailscale repos: this client enrols new
# machines as tag:den, which is a larger thing than reading a client ID.
resource "tailscale_oauth_client" "den" {
  description = "den host enrolment"
  scopes      = ["auth_keys", "devices:core"]
  tags        = ["tag:den"]
}

# den's half of the tailnet config, read by `den apply` on the operator's
# laptop. Never folded into den-host: den itself has no use for either value.
module "den" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "tailscale-den"
  data = {
    CLIENT_ID     = tailscale_oauth_client.den.id
    CLIENT_SECRET = tailscale_oauth_client.den.key
  }
}
