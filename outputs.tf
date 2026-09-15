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
