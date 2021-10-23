dependency "dependency" {
    config_path = "../dependency"
}

// include "generate" {
//       path = find_in_parent_folders("generate.hcl")
// }

// include "remote_state" {
//       path = find_in_parent_folders("remote-state.hcl")
// }

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git///modules/test-error/"
}
