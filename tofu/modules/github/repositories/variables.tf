variable "owner" {
  description = "GitHub owner (user or organization) for these repositories"
  type        = string
}

variable "repositories" {
  description = "Map of repository names to their configuration"
  type = map(object({
    # Opt the repository into the weekly conformance bot (mklv-conform topic).
    conform     = optional(bool, true)
    description = optional(string, "")
    # Issues are off unless a repository needs them.
    has_issues = optional(bool, false)
    topics     = optional(list(string), [])
    visibility = optional(string, "public")
  }))
}

variable "secrets" {
  description = "Map of secret names to values, applied to repos with mklv-deploy topic"
  type        = map(string)
  default     = {}
  sensitive   = true
}
