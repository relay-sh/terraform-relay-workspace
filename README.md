# terraform-relay-workspace

Creates a Relay workspace with its connections, API keys, IP access list and
private endpoint services. Every connection takes its unset fields from
`connection_defaults`, so a workspace that routes everything through one agent
pool and one secret source states that once.

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

`api_keys` creates keys confined to the workspace, keyed by name. Their secrets
come out of `api_key_secrets` once, at creation. A key with `expires_in` is
replaced by the first apply after it expires, so its secret changes then and
whatever reads `api_key_secrets` has to pick up the new value.

`ip_access_list` and `private_endpoint_services` set up the workspace's
network. The module stops at the service: registering a cloud endpoint on it
takes your own `aws_vpc_endpoint`, so `relay_private_endpoint` lives next to it
in your configuration. The platform accepts the connection by itself; see
`examples/complete`.

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
| [relay_api_key.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/api_key) | resource |
| [relay_connection.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/connection) | resource |
| [relay_ip_access_list.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/ip_access_list) | resource |
| [relay_private_endpoint_service.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/private_endpoint_service) | resource |
| [relay_workspace.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Workspace name, unique in the organization. | `string` | n/a | yes |
| <a name="input_api_keys"></a> [api\_keys](#input\_api\_keys) | API keys confined to the workspace, keyed by key name. | <pre>map(object({<br/>    role          = string<br/>    allowed_cidrs = optional(set(string))<br/>    expires_in    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_connection_defaults"></a> [connection\_defaults](#input\_connection\_defaults) | Values applied to every connection that does not set them. | <pre>object({<br/>    agent_pool        = optional(string, "default")<br/>    credential_source = optional(string, "")<br/>    audit_enabled     = optional(bool, true)<br/>    redact_enabled    = optional(bool, false)<br/>    policy_fail_mode  = optional(string, "")<br/>    host_tls_ca       = optional(string, "")<br/>  })</pre> | `{}` | no |
| <a name="input_connection_passwords"></a> [connection\_passwords](#input\_connection\_passwords) | Passwords keyed by connection name. Kept apart from connections so the map can be iterated; prefer credential\_ref. | `map(string)` | `{}` | no |
| <a name="input_connection_tls_keys"></a> [connection\_tls\_keys](#input\_connection\_tls\_keys) | Client TLS keys keyed by connection name. | `map(string)` | `{}` | no |
| <a name="input_connections"></a> [connections](#input\_connections) | Connections to create in the workspace, keyed by connection name. | <pre>map(object({<br/>    engine              = string<br/>    host                = string<br/>    user                = optional(string, "")<br/>    credential_ref      = optional(string, "")<br/>    credential_source   = optional(string)<br/>    database            = optional(string, "")<br/>    listen              = optional(string, "")<br/>    agent_pool          = optional(string)<br/>    managed_database_id = optional(string)<br/>    audit_enabled       = optional(bool)<br/>    redact_enabled      = optional(bool)<br/>    policy_fail_mode    = optional(string)<br/>    redact_rules = optional(list(object({<br/>      column_pattern = string<br/>      strategy       = string<br/>      partial_show   = optional(number, 0)<br/>    })))<br/>    tls_cert    = optional(string, "")<br/>    tls_ca      = optional(string, "")<br/>    host_tls_ca = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Workspace description. | `string` | `""` | no |
| <a name="input_ip_access_list"></a> [ip\_access\_list](#input\_ip\_access\_list) | Networks allowed to reach the workspace's public database endpoints, as canonical CIDR => description. | `map(string)` | `{}` | no |
| <a name="input_private_endpoint_services"></a> [private\_endpoint\_services](#input\_private\_endpoint\_services) | Private endpoint services keyed by a label of your choice. Register cloud endpoints on them with relay\_private\_endpoint. | <pre>map(object({<br/>    cloud  = optional(string, "aws")<br/>    region = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_api_key_secrets"></a> [api\_key\_secrets](#output\_api\_key\_secrets) | API key secrets by name. Returned once, at creation; null for imported keys. |
| <a name="output_api_keys"></a> [api\_keys](#output\_api\_keys) | Created API keys by name. |
| <a name="output_connections"></a> [connections](#output\_connections) | Created connections by name. |
| <a name="output_ip_access_list"></a> [ip\_access\_list](#output\_ip\_access\_list) | IP access list entry IDs by CIDR. |
| <a name="output_private_endpoint_services"></a> [private\_endpoint\_services](#output\_private\_endpoint\_services) | Private endpoint services by label, with the endpoint\_service\_name a cloud endpoint connects to. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Workspace ID. |
| <a name="output_workspace_slug"></a> [workspace\_slug](#output\_workspace\_slug) | Workspace slug. |
<!-- END_TF_DOCS -->
