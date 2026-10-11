# 1. Every stack is a Terramate stack with generated providers

This decision records the shape of the repository: what a stack is, where its
state lives, and why no stack writes its own provider block.

## Context

The repository holds around twenty stacks across five providers. Every one of
them needs the same three things: a GCS backend, a pinned set of providers, and
a path to the shared modules. Written by hand, those blocks drift. One stack
ends up a provider minor behind, another points at a state prefix that collides
with its neighbour, and nothing fails loudly enough to notice.

## Decision

**A stack is a directory with a `stack.tm.hcl`, and everything mechanical about
it is generated.**

- **Provider and backend configuration is generated into `_tofu.tf`.** The
  area-level `terramate.tm.hcl` (`gcp/`, `github/`, `namecheap/`, `supabase/`,
  `tailscale/`) declares a `generate_hcl` block, and `terramate generate` writes
  it into every stack beneath. The file is generated output: edit the template,
  never the result.
- **Provider versions are pinned once, at the repository root.** An area adds
  only the providers it actually uses. Upgrading is a single edit followed by
  `terramate script run upgrade`.
- **State prefix is `tfstate/<stack path>`.** Derived from
  `terramate.stack.path.relative`, so a stack's state location is a consequence
  of where it sits, not a thing anyone chooses. Two stacks cannot collide
  without also colliding on disk.
- **Modules are addressed through `local.modules_dir`,** an absolute path
  computed from the stack's depth. A module reference is therefore identical in
  every stack regardless of nesting.
- **Ordering is declared with `after`, never implied.** A stack that reads
  another's remote state must say so. Terramate orders the run from those edges.

## Consequences

Changing a module path means re-running `terramate script run init` before
committing, because each stack caches the old path and `tofu validate` fails
with "Module source has changed".

`.tf` files remain `.tf` even though the tooling is OpenTofu. The native `.tofu`
extension works, but the CI detection step and the lefthook hooks both gate on
`git ls-files '*.tf'` and fail closed: a repository that renamed its files would
stop being validated and deployed, with no error anywhere.
