# terraform-relay-workspace

Creates a Relay workspace and its connections. Every connection takes its
unset fields from `connection_defaults`, so a workspace that routes everything
through one agent pool and one secret source states that once.

```hcl
module "workspace" {
  source  = "relay-sh/workspace/relay"
  version = "~> 0.0.1"

  name = "prod"

  connection_defaults = {
    agent_pool        = "default"
    credential_source = "vault-prod"
  }

  connections = {
    orders = {
      engine         = "postgres"
      host           = "orders.internal:5432"
      credential_ref = "secret/data/orders#password"
    }
  }
}
```

Passwords and client TLS keys go in `connection_passwords` and
`connection_tls_keys`, keyed by connection name. They are separate because
Terraform cannot iterate a map that holds sensitive values. Prefer
`credential_ref` so no password lives in state.

Upstream TLS is always on. Only its CA can be set.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_relay"></a> [relay](#requirement\_relay) | ~> 0.0.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_relay"></a> [relay](#provider\_relay) | ~> 0.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [relay_connection.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/connection) | resource |
| [relay_workspace.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Workspace name, unique in the organization. | `string` | n/a | yes |
| <a name="input_connection_defaults"></a> [connection\_defaults](#input\_connection\_defaults) | Values applied to every connection that does not set them. | <pre>object({<br/>    agent_pool        = optional(string, "default")<br/>    kind              = optional(string, "interactive")<br/>    credential_source = optional(string, "")<br/>    audit_enabled     = optional(bool, true)<br/>    redact_enabled    = optional(bool, false)<br/>    policy_fail_mode  = optional(string, "")<br/>    host_tls_ca       = optional(string, "")<br/>  })</pre> | `{}` | no |
| <a name="input_connection_passwords"></a> [connection\_passwords](#input\_connection\_passwords) | Passwords keyed by connection name. Kept apart from connections so the map can be iterated; prefer credential\_ref. | `map(string)` | `{}` | no |
| <a name="input_connection_tls_keys"></a> [connection\_tls\_keys](#input\_connection\_tls\_keys) | Client TLS keys keyed by connection name. | `map(string)` | `{}` | no |
| <a name="input_connections"></a> [connections](#input\_connections) | Connections to create in the workspace, keyed by connection name. | <pre>map(object({<br/>    engine              = string<br/>    host                = string<br/>    user                = optional(string, "")<br/>    credential_ref      = optional(string, "")<br/>    credential_source   = optional(string)<br/>    database            = optional(string, "")<br/>    listen              = optional(string, "")<br/>    agent_pool          = optional(string)<br/>    kind                = optional(string)<br/>    managed_database_id = optional(string)<br/>    audit_enabled       = optional(bool)<br/>    redact_enabled      = optional(bool)<br/>    policy_fail_mode    = optional(string)<br/>    redact_rules = optional(list(object({<br/>      column_pattern = string<br/>      strategy       = string<br/>      partial_show   = optional(number, 0)<br/>    })))<br/>    tls_cert    = optional(string, "")<br/>    tls_ca      = optional(string, "")<br/>    host_tls_ca = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Workspace description. | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_connections"></a> [connections](#output\_connections) | Created connections by name. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Workspace ID. |
| <a name="output_workspace_slug"></a> [workspace\_slug](#output\_workspace\_slug) | Workspace slug. |
<!-- END_TF_DOCS -->
