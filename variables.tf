variable "name" {
  description = "Workspace name, unique in the organization."
  type        = string
}

variable "description" {
  description = "Workspace description."
  type        = string
  default     = ""
}

variable "connection_defaults" {
  description = "Values applied to every connection that does not set them."
  type = object({
    agent_pool        = optional(string, "default")
    credential_source = optional(string, "")
    audit_enabled     = optional(bool, true)
    redact_enabled    = optional(bool, false)
    policy_fail_mode  = optional(string, "")
    host_tls_ca       = optional(string, "")
  })
  default = {}
}

variable "connections" {
  description = "Connections to create in the workspace, keyed by connection name."
  type = map(object({
    engine              = string
    host                = string
    user                = optional(string, "")
    credential_ref      = optional(string, "")
    credential_source   = optional(string)
    database            = optional(string, "")
    listen              = optional(string, "")
    agent_pool          = optional(string)
    managed_database_id = optional(string)
    audit_enabled       = optional(bool)
    redact_enabled      = optional(bool)
    policy_fail_mode    = optional(string)
    redact_rules = optional(list(object({
      column_pattern = string
      strategy       = string
      partial_show   = optional(number, 0)
    })))
    tls_cert    = optional(string, "")
    tls_ca      = optional(string, "")
    host_tls_ca = optional(string)
  }))
  default = {}
}

variable "connection_passwords" {
  description = "Passwords keyed by connection name. Kept apart from connections so the map can be iterated; prefer credential_ref."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "connection_tls_keys" {
  description = "Client TLS keys keyed by connection name."
  type        = map(string)
  default     = {}
  sensitive   = true
}
