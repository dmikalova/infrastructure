# One-time imports of repositories created outside tofu. Delete this file once
# they are applied.

import {
  to = module.repositories.github_repository.repos["droid"]
  id = "droid"
}

import {
  to = module.repositories.github_repository.repos["factorio-mods"]
  id = "factorio-mods"
}

import {
  to = module.repositories.github_repository.repos["keyforge-scripts"]
  id = "keyforge-scripts"
}
