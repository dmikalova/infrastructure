# GitHub stacks - generate Terraform config using centralized provider versions

generate_hcl "_terraform.tf" {
  content {
    terraform {
      required_version = ">= 1.8"

      backend "gcs" {
        bucket = global.state_bucket
        prefix = "tfstate/${terramate.stack.path.relative}"
      }

      required_providers {
        github = {
          source  = "integrations/github"
          version = global.provider_versions.github
        }
        sops = {
          source  = "nobbs/sops"
          version = global.provider_versions.sops
        }
      }
    }

    locals {
      repo_root   = terramate.stack.path.to_root
      modules_dir = abspath("${path.root}/${local.repo_root}/terraform/modules")
    }

    provider "github" {
      owner = global.github_owner
      token = provider::sops::file("${local.repo_root}/secrets/github.sops.json").data.GITHUB_TOKEN
    }

    provider "sops" {}
  }
}
