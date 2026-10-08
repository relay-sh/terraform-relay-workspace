resource "relay_workspace" "this" {
  name        = var.name
  description = var.description
}

resource "relay_connection" "this" {
  for_each = var.connections

  workspace_id        = relay_workspace.this.id
  name                = each.key
  engine              = each.value.engine
  host                = each.value.host
  user                = each.value.user
  password            = lookup(var.connection_passwords, each.key, null)
  credential_ref      = each.value.credential_ref
  credential_source   = each.value.credential_source != null ? each.value.credential_source : var.connection_defaults.credential_source
  database            = each.value.database
  listen              = each.value.listen
  agent_pool          = coalesce(each.value.agent_pool, var.connection_defaults.agent_pool)
  managed_database_id = each.value.managed_database_id
  audit_enabled       = coalesce(each.value.audit_enabled, var.connection_defaults.audit_enabled)
  redact_enabled      = coalesce(each.value.redact_enabled, var.connection_defaults.redact_enabled)
  policy_fail_mode    = each.value.policy_fail_mode != null ? each.value.policy_fail_mode : var.connection_defaults.policy_fail_mode
  redact_rules        = each.value.redact_rules
  tls_cert            = each.value.tls_cert
  tls_key             = lookup(var.connection_tls_keys, each.key, "")
  tls_ca              = each.value.tls_ca
  host_tls_ca         = each.value.host_tls_ca != null ? each.value.host_tls_ca : var.connection_defaults.host_tls_ca
}

resource "relay_api_key" "this" {
  for_each = var.api_keys

  workspace_id  = relay_workspace.this.id
  name          = each.key
  role          = each.value.role
  allowed_cidrs = each.value.allowed_cidrs
  expires_in    = each.value.expires_in
}

resource "relay_ip_access_list" "this" {
  for_each = var.ip_access_list

  workspace_id = relay_workspace.this.id
  cidr         = each.key
  description  = each.value
}

resource "relay_private_endpoint_service" "this" {
  for_each = var.private_endpoint_services

  workspace_id = relay_workspace.this.id
  cloud        = each.value.cloud
  region       = each.value.region
}
