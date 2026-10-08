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

variable "api_keys" {
  description = "API keys confined to the workspace, keyed by key name."
  type = map(object({
    role          = string
    allowed_cidrs = optional(set(string))
    expires_in    = optional(string)
  }))
  default = {}
}

variable "ip_access_list" {
  description = "Networks allowed to reach the workspace's public database endpoints, as canonical CIDR => description."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_services" {
  description = "Private endpoint services keyed by a label of your choice. Register cloud endpoints on them with relay_private_endpoint."
  type = map(object({
    cloud  = optional(string, "aws")
    region = string
  }))
  default = {}
}
