include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "e91e63"
    repositories = {
      terraform-digitalocean-account = {
        description = "Terraform modules for managing Digital Ocean accounts"
        visibility  = "public"
      },
      terraform-digitalocean-kubernetes = {
        description = "Terraform modules for deploying a Digital Ocean Kubernetes cluster"
        visibility  = "public"
      },
      terraform-digitalocean-networking = {
        description = "Terraform modules for managing Digital Ocean networking resources"
        visibility  = "public"
      },
      terraform-digitalocean-postgresql = {
        description = "Terraform modules for managing Digital Ocean PostgreSQL databases"
        visibility  = "public"
      },
      terraform-digitalocean-spaces = {
        description = "Terraform modules for Digital Ocean spaces"
        visibility  = "public"
      },
      terraform-github-repositories = {
        description = "Terraform modules for managing Github Repositories"
        visibility  = "public"
      },
      terraform-gitlab-projects = {
        description = "Terraform modules for managing Gitlab Projects and related resources"
        visibility  = "public"
      },
      terraform-kubernetes-manifests = {
        description = "Terraform modules for managing Kubernetes manifests"
        visibility  = "public"
      },
      terraform-tekton-pipelines = {
        description = "Terraform modules for building reusable Tekton pipelines"
        visibility  = "public"
      },
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
