# 4. GitHub repository topics drive infrastructure

This decision records how a repository asks for infrastructure without any
stack naming it.

## Context

Several stacks need a list of repositories: which ones may deploy to Cloud Run,
which ones may mint a Tailscale auth key, which ones get a custom domain, which
ones the conformance bot rewrites. Maintaining those lists by hand means every
new service touches several stacks, and the lists drift apart.

## Decision

**A repository's topics are the single source of truth for what it is entitled
to.**

- **`github/dmikalova` owns the topics.** They are declared alongside the
  repository, in one place.
- **Dependent stacks filter on them.** The workload identity stack binds the
  deploy service account to repositories carrying `mklv-deploy`; the tailnet
  stack mints a federated identity for each repository carrying
  `mklv-tailscale`; a domain topic selects which zone an app's custom domain
  lands in.
- **Every consuming stack declares `after = ["/github/dmikalova"]`,** because a
  topic must exist before anything can filter on it.

## Consequences

Granting a repository access to something is a one-line change in one stack,
and revoking it is the same line. The entitlement is visible on the repository
itself rather than buried in an IAM binding.

A topic is public on a public repository. It reveals that a repository has some
relationship to this infrastructure, which is acceptable because the topic
grants nothing on its own — the binding it drives is still scoped to a verified
OIDC subject (ADR 0008).

Removing a topic silently removes access on the next apply. That is the
intended behaviour, but it means a careless topic edit is a production change.
