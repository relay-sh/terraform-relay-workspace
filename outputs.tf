output "workspace_id" {
  description = "Workspace ID."
  value       = relay_workspace.this.id
}

output "workspace_slug" {
  description = "Workspace slug."
  value       = relay_workspace.this.slug
}

output "connections" {
  description = "Created connections by name."
  value = {
    for name, c in relay_connection.this : name => {
      id     = c.id
      status = c.status
    }
  }
}

output "api_keys" {
  description = "Created API keys by name."
  value = {
    for name, k in relay_api_key.this : name => {
      id         = k.id
      expires_at = k.expires_at
    }
  }
}

output "api_key_secrets" {
  description = "API key secrets by name. Returned once, at creation; null for imported keys."
  value       = { for name, k in relay_api_key.this : name => k.secret }
  sensitive   = true
}

output "ip_access_list" {
  description = "IP access list entry IDs by CIDR."
  value       = { for cidr, e in relay_ip_access_list.this : cidr => e.id }
}

output "private_endpoint_services" {
  description = "Private endpoint services by label, with the endpoint_service_name a cloud endpoint connects to."
  value = {
    for label, s in relay_private_endpoint_service.this : label => {
      id                    = s.id
      endpoint_service_name = s.endpoint_service_name
    }
  }
}
