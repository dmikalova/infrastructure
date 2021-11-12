dependency "gitlab_projects" {
  config_path = find_in_parent_folders("projects")
}

dependency "workflows" {
  config_path = find_in_parent_folders("digitalocean/e91e63/services/tekton/workflows")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  gitlab_projects_info = dependency.gitlab_projects.outputs.info
  workflows_info       = dependency.workflows.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-gitlab-projects.git///modules/webhooks"
}
