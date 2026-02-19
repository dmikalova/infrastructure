# Tasks

## Phase 1: Preparation

### 1.1 Backup existing state (MANUAL)

**Owner:** User

Backup all Terragrunt state files before migration:

```bash
cd github/dmikalova
terragrunt state pull > ~/github-dmikalova.tfstate.backup

cd ../cddc39
terragrunt state pull > ~/github-cddc39.tfstate.backup

cd ../e91e63
terragrunt state pull > ~/github-e91e63.tfstate.backup

cd ../screeptorio
terragrunt state pull > ~/github-screeptorio.tfstate.backup
```

Store backups in a safe location outside the repo.

---

### 1.2 Create local GitHub repositories module

**Owner:** Agent

Create `terraform/modules/github/repositories/` with:

- `main.tf` - `github_repository` resource with for_each
- `variables.tf` - owner, repositories map
- `outputs.tf` - repository URLs

Based on existing `e91e63/terraform-github-repositories` module but simplified.

---

### 1.3 Create Terramate config for GitHub

**Owner:** Agent

Create `github/terramate.tm.hcl` with:

- GCS backend generation (prefix: `tfstate/github/`)
- GitHub provider using SOPS for token
- SOPS provider config

---

## Phase 2: Repository Consolidation (MANUAL)

### 2.1 Transfer cddc39 repos to dmikalova (MANUAL)

**Owner:** User

Transfer repos using GitHub CLI:

```bash
gh repo transfer cddc39/lists dmikalova
gh repo transfer cddc39/recipes dmikalova
gh repo transfer cddc39/todos dmikalova
```

Wait for each transfer to complete before proceeding.

**Verification:** Visit `github.com/dmikalova/lists` etc. to confirm ownership.

---

### 2.2 Delete screeptorio repos (MANUAL)

**Owner:** User

Delete all screeptorio repos via GitHub UI:

1. Go to each repo → Settings → Danger Zone → Delete
2. Repos to delete: (list from current state - check `github/screeptorio/`)

After deleting repos, delete the organization:

- Organization settings → Delete organization

---

### 2.3 Delete e91e63 terraform-\* repos (MANUAL)

**Owner:** User

Delete terraform module repos via GitHub UI (keeping the user account):

1. `e91e63/terraform-github-repositories`
2. Any other `terraform-*` repos under e91e63

These modules are obsolete - functionality merged into infrastructure repo.

---

## Phase 3: Terramate Migration

### 3.1 Create dmikalova Terramate stack

**Owner:** Agent

Create `github/dmikalova/`:

- `stack.tm.hcl` - stack definition with `github_owner = "dmikalova"`
- `main.tf` - module call with all repositories listed

Include all existing dmikalova repos plus:

- `email-unsubscribe` (new)
- `github-meta` (new)
- `lists`, `recipes`, `todos` (transferred from cddc39)

---

### 3.2 Generate Terramate files

**Owner:** Agent/User

```bash
cd github
terramate generate
```

Verify generated `_backend.tf` and `_providers.tf` files.

---

### 3.3 Initialize and push state (MANUAL)

**Owner:** User

Initialize with new GCS backend and push existing state:

```bash
cd github/dmikalova
tofu init

# Push the backed-up state
tofu state push ~/github-dmikalova.tfstate.backup
```

---

### 3.4 Verify state migration

**Owner:** User

Run plan and verify:

```bash
tofu plan
```

Expected output:

- **No changes** for existing repos (brocket, dmikalova, dotfiles,
  infrastructure, synths)
- **Create** for new repos (email-unsubscribe, github-meta)
- **No changes** for transferred repos IF state addresses match

If transferred repos show as "create", we need to move state resources:

```bash
# Only if needed - adjust addresses based on actual module structure
tofu state mv 'module.old_address' 'module.repositories.github_repository.repos["lists"]'
```

---

### 3.5 Apply changes (MANUAL)

**Owner:** User

```bash
tofu apply
```

Creates `email-unsubscribe` and `github-actions` repos.

---

## Phase 4: Cleanup

### 4.1 Delete old Terragrunt files

**Owner:** Agent

Remove old Terragrunt configuration:

- `github/dmikalova/terragrunt.hcl`
- `github/cddc39/` directory
- `github/e91e63/` directory
- `github/screeptorio/` directory
- `github/digitalocean.hcl`, `github/helm.hcl`, `github/kubectl.hcl`,
  `github/kubernetes.hcl` (if GitHub-specific)

Keep:

- `github/README.md` (update with new instructions)

---

### 4.2 Update GitHub README

**Owner:** Agent

Update `github/README.md` to document:

- New Terramate-based workflow
- How to add/modify repositories
- State location in GCS

---

### 4.3 Archive DO Spaces state (MANUAL)

**Owner:** User

Document or archive the old DigitalOcean Spaces state location for reference.
The state is no longer needed but may be useful for historical reference.

---

## Verification Checklist

After completion, verify:

- [ ] All dmikalova repos accessible and unchanged
- [ ] `email-unsubscribe` repo created
- [ ] `github-actions` repo created
- [ ] `lists`, `recipes`, `todos` owned by dmikalova
- [ ] screeptorio org deleted
- [ ] e91e63 terraform-\* repos deleted
- [ ] `tofu plan` shows no changes
- [ ] Old Terragrunt files removed
- [ ] State backups archived
