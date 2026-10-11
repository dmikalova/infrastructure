# 7. An app owns a stack, a schema and a role

This decision records the isolation boundary between applications sharing one
Supabase project and one GCP project.

## Context

Applications share a database and a cloud project for cost reasons. Shared
infrastructure with unscoped credentials means any application's compromise is
every application's compromise.

## Decision

**Each application gets its own stack, its own schema and its own database
role, all named from the application.**

- **One Terramate stack per app, at `gcp/apps/<app>/`.** An app can be applied
  without touching its neighbours, and its blast radius is its own directory.
- **One Postgres schema per app**, named by replacing hyphens with underscores,
  because Postgres identifiers do not take hyphens.
- **One Postgres role per app**, named `<app>-role`, granted `CREATE` and
  `USAGE` on its own schema and DML on its own tables. It is granted nothing on
  any other schema.
- **The app's connection string is written to Secret Manager as
  `<app>-database-url`** and read by that app alone.

## Consequences

The hyphen-to-underscore conversion is a silent contract. An application named
`email-unsubscribe` gets the schema `email_unsubscribe`, and code that assumes
the literal name looks in a schema that does not exist. The conversion happens
in one place in the module so that the rule is at least singular.

Shared infrastructure stays shared: the project, the Artifact Registry and the
Supabase project are common. The isolation is of data and credentials, not of
spend or availability.
