dependency "dependency" {
    config_path = find_in_parent_folders("dependency")
}

// include "generate" {
//       path = find_in_parent_folders("generate.hcl")
// }

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git///modules/test-error/"
}
