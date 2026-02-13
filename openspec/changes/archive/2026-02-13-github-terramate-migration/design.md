## Context

GitHub repository management currently lives in `github/*/terragrunt.hcl` files, using:

- Terragrunt for orchestration
- DigitalOcean Spaces (S3-compatible) for state storage
- External module `e91e63/terraform-github-repositories`
- Dependency on DigitalOcean Tekton workflows (obsolete)
- GPG/SSH keys for Tekton CI (obsolete)

Current repos managed:

- `dmikalova`: brocket, dmikalova, dotfiles, infrastructure, synths (5 repos) → **keep as-is**
- `e91e63`: 8 terraform-\* repos → **delete all** (github-repos module merged into infra)
- `cddc39`: lists, recipes, todos (3 repos) → **migrate to dmikalova**
- `screeptorio`: 3 repos (organization) → **delete org and repos**

## Goals / Non-Goals

**Goals:**

- Migrate GitHub repo management from Terragrunt to Terramate at `github/`
- Move state from DO Spaces to GCS via state pull/push (no re-import)
- Consolidate repos under dmikalova owner
- Remove GPG/SSH keys and Tekton dependencies
- Add `email-unsubscribe` repo to dmikalova
- Delete screeptorio and e91e63 owners/repos

**Non-Goals:**

- Moving github/ to gcp/ (stays at root)
- Re-importing resources (migrate state in place)
- Preserving Tekton CI infrastructure

## Decisions

### 1. Stack Structure

**Decision:** Terramate stacks stay at `github/` root. After consolidation, only `github/dmikalova/` remains.

```
github/
├── terramate.tm.hcl      # GitHub-specific provider config
└── dmikalova/
    ├── stack.tm.hcl
    └── main.tf
```

**Alternatives considered:**

- Move to `gcp/github/`: Would imply it's GCP resources, but it's GitHub
- Keep multiple owner stacks: Unnecessary after consolidation

**Rationale:** GitHub management is not GCP infrastructure - it just uses GCS for state. Keeping at `github/` maintains logical separation.

### 2. State Migration Strategy

**Decision:** Pull state from DO Spaces, push to GCS. No re-import needed.

```bash
# Backup existing state:
cd github/dmikalova
terragrunt state pull > terraform.tfstate.backup

# After converting to Terramate:
tofu init -backend-config="bucket=mklv-infrastructure-tfstate"
tofu state push terraform.tfstate.backup
tofu plan  # Should show no changes for existing repos
```

**Alternatives considered:**

- Fresh import: Loses state history, risk of address mismatch
- Keep DO Spaces: Creates dependency on DigitalOcean

**Rationale:** State pull/push preserves resource addresses exactly. Terraform sees the same state, just in a new backend.

### 3. GitHub Provider Configuration

**Decision:** Add GitHub-specific terramate.tm.hcl in `github/` directory.

```hcl
# github/terramate.tm.hcl
generate_hcl "_backend.tf" {
  content {
    terraform {
      backend "gcs" {
        bucket = "mklv-infrastructure-tfstate"
        prefix = "tfstate/github/${terramate.stack.path.basename}"
      }
    }
  }
}

generate_hcl "_providers.tf" {
  content {
    terraform {
      required_providers {
        github = {
          source  = "integrations/github"
          version = "~> 6.0"
        }
        sops = {
          source  = "nobbs/sops"
          version = "~> 0.3"
        }
      }
    }

    provider "github" {
      owner = global.github_owner
      token = provider::sops::file("${terramate.root.path.fs.absolute}/secrets/github.sops.json").data.TOKEN
    }

    provider "sops" {}
  }
}
```

**Rationale:** Separate terramate.tm.hcl for GitHub keeps config isolated from GCP stacks. Uses same SOPS pattern for secrets.

### 4. Resource Definition Approach

**Decision:** Define repos using a local module at `terraform/modules/github/repositories`.

```hcl
# github/dmikalova/main.tf
module "repositories" {
  source = "../../terraform/modules/github/repositories"

  owner = "dmikalova"
  repositories = {
    brocket           = { description = "run-or-raise script" }
    dmikalova         = { description = "personal profile" }
    dotfiles          = { description = "personal dotfiles" }
    email-unsubscribe = { description = "Gmail inbox cleanup automation" }
    github-meta       = { description = "reusable workflows, Dagger pipelines, and repo standards" }
    infrastructure    = { description = "terramate infrastructure configuration" }
    lists             = { description = "manage lists" }        # migrated from cddc39
    recipes           = { description = "manage recipes" }      # migrated from cddc39
    synths            = { description = "personal synth notes" }
    todos             = { description = "manage todos" }        # migrated from cddc39
  }
}
```

**Alternatives considered:**

- Keep using `e91e63/terraform-github-repositories` external module: Being deleted
- Define repos inline without module: Less reusable

**Rationale:** Local module replaces external `e91e63/terraform-github-repositories`. Keeps module code in this repo for maintainability.

### 5. cddc39 Repo Migration

**Decision:** Transfer repos to dmikalova via GitHub CLI before state migration.

```bash
gh repo transfer cddc39/lists dmikalova
gh repo transfer cddc39/recipes dmikalova
gh repo transfer cddc39/todos dmikalova
```

Then add to dmikalova's Terraform config. Old cddc39 state can be discarded.

**Rationale:** GitHub's repo transfer preserves issues, PRs, stars. Cleaner than recreating.

### 6. Deletion of screeptorio and e91e63

**Decision:** Delete via GitHub UI/CLI before removing from Terraform.

- **screeptorio**: Delete repos first, then org. Archive state for reference.
- **e91e63**: Delete all terraform-\* repos (module code merged into infra). Keep user account.

**Rationale:** Manual deletion via GitHub is safer than `terraform destroy` for permanent deletions.

### 7. GPG/SSH Key Removal

**Decision:** Remove GPG and SSH key management entirely.

**Rationale:** Keys were for Tekton CI which is being replaced. WIF doesn't need deploy keys.

## Risks / Trade-offs

| Risk                         | Mitigation                                          |
| ---------------------------- | --------------------------------------------------- |
| State push fails             | Backup state files before migration                 |
| Repo transfer loses settings | Verify settings post-transfer                       |
| Wrong resource addresses     | Run `tofu plan` after state push, verify no changes |
| Delete wrong repos           | Manual deletion via GitHub UI with confirmation     |

## Migration Plan

### Phase 1: Preparation

1. **Backup all state** - `terragrunt state pull` for each stack
2. **Create local module** - `terraform/modules/github/repositories`
3. **Create Terramate config** - `github/terramate.tm.hcl`

### Phase 2: Repo Consolidation (via GitHub UI/CLI)

4. **Transfer cddc39 repos to dmikalova** - Using `gh repo transfer`
5. **Delete screeptorio repos and org** - Via GitHub UI
6. **Delete e91e63 repos** - Via GitHub UI (keep user account)

### Phase 3: Terramate Migration

7. **Create dmikalova stack** - `github/dmikalova/` with new config
8. **Push state to GCS** - `tofu state push` from backup
9. **Verify with plan** - Should show only `email-unsubscribe` as new
10. **Apply** - Creates new repo

### Phase 4: Cleanup

11. **Delete old Terragrunt files** - Remove `github/*/terragrunt.hcl`
12. **Archive DO Spaces state** - Document location for reference

Rollback: State backups allow reverting to Terragrunt if needed.

## Open Questions

None - all resolved.
