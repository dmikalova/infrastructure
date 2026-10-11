# 3. CI applies every stack except those tagged manual

This decision records what a push to `main` does, and the one escape hatch from
it.

## Context

A push to `main` runs `terramate script run --no-tags=manual cicd`, which is
`tofu init`, `tofu validate`, `tofu apply -auto-approve` across the run order.
The repository is therefore the state of the world, and drift is corrected
without anyone asking.

Some stacks cannot run that way. The Namecheap API answers only source IPs that
have been added to an allowlist in the Namecheap account, and a GitHub runner's
address is neither fixed nor known in advance. No amount of credential handling
fixes that.

## Decision

**`manual` means CI is incapable of running the stack, not that the stack is
risky.**

- **A stack tagged `manual` is excluded from the deploy job** and is applied by
  hand. That is its sanctioned path, not a workaround.
- **Risk alone is not a reason to tag a stack `manual`.** A dangerous stack
  should carry a guard that fails the apply — the Tailscale policy file has a
  `tests` block for exactly this — rather than relying on a human being present.
- **`namecheap/domains` is the only stack that qualifies today.**

## Consequences

**A green pipeline is not proof that a `manual` stack applied.** Nothing reports
the exclusion; the run simply does not mention the stack. This cost real time
once: a committed, pushed and apparently deployed Tailscale change had never
been applied, and the pipeline was briefly blamed for a fault it did not have.

When adding the tag, record the reason beside it. "Why is this manual" is not
recoverable from git history once the original commit is old.
