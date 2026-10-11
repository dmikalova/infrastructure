# 9. Federated identities are pinned by numeric id

This decision records how the tailnet trusts a GitHub workflow, and why the
subject pattern contains numbers nobody chose.

## Context

CI needs to join the tailnet to reach `den`. Tailscale can trust a GitHub OIDC
token directly, which avoids storing a tailnet auth key in a secret anywhere.

The trust is expressed as a subject pattern matched against the token's `sub`
claim. The obvious pattern, `repo:dmikalova/den:*`, never matches. GitHub now
issues immutable subjects that carry numeric ids:

```
repo:dmikalova@324548/den@1412746511:ref:refs/heads/main
```

A mismatch returns a bare 403 with no indication of which claim failed.

## Decision

**The subject is built from discrete values and pins both numeric ids.**

- **The owner id and repository id come from the GitHub stack's remote state,**
  not from literals. `github_repository.repo_id` and the `github_user` data
  source expose them; the tailnet stack reads them across the state boundary.
- **Only the ref is a wildcard.** Owner and repository are fully pinned.
- **No `try()` around the ids.** A missing id must fail the apply. Silently
  widening a trust pattern is worse than not applying it.

## Consequences

Pinning the ids is what makes the trust meaningful. A login or a repository
name can be released and re-registered by somebody else; the numeric id cannot.
A pattern wildcarded to `dmikalova@*/den@*` would survive that transfer and
keep trusting the new owner.

The cost is that the pattern is unreadable, and that a rejected exchange
explains itself only in the Tailscale admin console. The stack therefore
outputs the console URL for each federated identity, so the explanation is one
click away rather than reconstructed from a failed job.
