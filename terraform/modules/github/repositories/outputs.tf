output "repositories" {
  description = "Map of repository names to their full details"
  value = {
    for name, repo in github_repository.repos : name => {
      full_name = repo.full_name
      html_url  = repo.html_url
      http_url  = repo.http_clone_url
      ssh_url   = repo.ssh_clone_url
      topics    = repo.topics
    }
  }
}

output "repository_names" {
  description = "List of repository names"
  value       = keys(github_repository.repos)
}
