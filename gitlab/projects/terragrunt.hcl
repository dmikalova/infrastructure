terraform {
  source = "git@gitlab.com:dmikalova/terraform-gitlab-projects.git"
}

include {
  path = find_in_parent_folders()
}


inputs = merge(
  jsondecode(file(find_in_parent_folders("projects-conf.json"))),
)
