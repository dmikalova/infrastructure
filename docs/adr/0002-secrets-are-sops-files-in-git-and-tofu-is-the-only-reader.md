# 2. Secrets are SOPS files in git, and tofu is the only reader

This decision records where a secret value originates, how it reaches the thing
that needs it, and why Secret Manager is a distribution mechanism rather than a
source of truth.

## Context

Three kinds of secret exist here, and they behave differently:

- values a human chose (an API key, a billing account id, a password),
- values a provider issued (a Tailscale auth key, a Supabase anon key),
- values nothing outside this repository needs to know (a database password).

A plan needs all three at plan time. A running Cloud Run service needs some of
them at request time, and cannot read a file in a git repository.

## Decision

**Every human-chosen secret lives in `secrets/*.sops.json`, encrypted to a
shared age recipient, and tofu decrypts it at plan time.**

- **Stacks read secrets with `provider::sops::file(...)` in `locals`.** The
  plaintext exists only in memory during the run.
- **Values a runtime consumer needs are written onward into GCP Secret
  Manager by tofu.** Secret Manager is how a secret gets _to_ a workload; it is
  never where the value is authored.
- **A value tofu can invent, tofu invents.** `random_password` produces the
  Supabase database passwords, so they exist in state and in Secret Manager but
  in no file and no human's memory.
- **The age key is the only bootstrap secret.** It is the one thing that cannot
  be stored encrypted in this repository.

## Consequences

**Moving a secret "into Secret Manager" does not remove the need for a SOPS
file.** Secret Manager has no opinion about where a value came from; something
must still supply it. A human-chosen value has exactly two honest homes: a SOPS
file in this repository, or a `random_password` that no human ever chose. There
is no third option that deletes the file.

A secret that tofu generates can only be recovered through GCP. That is
acceptable for a database password, and not acceptable for anything that
unlocks hardware, which needs an escrow copy outside this system.
