# Infrastructure Secrets

This folder contains all of the secrets shared among Terragrunt configurations.

## Usage

Terragrunt configurations can use secrets as inputs using the `sops_decrypt_file` function:

```hcl
inputs = {
  example = local.secrets.example
}

locals {
  secrets = {
    example = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/example.sops.json")))
  }
}
```
