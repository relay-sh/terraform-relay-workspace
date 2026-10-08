mock_provider "relay" {
  mock_resource "relay_workspace" {
    defaults = {
      id   = "ws-123"
      slug = "prod"
    }
  }
  mock_resource "relay_api_key" {
    defaults = {
      id     = "key-1"
      secret = "rly_key_mock"
    }
  }
  mock_resource "relay_connection" {
    defaults = {
      id     = "conn-1"
      status = "unknown"
    }
  }
}

variables {
  name = "prod"
  connection_defaults = {
    agent_pool        = "pool-a"
    credential_source = "vault"
  }
  connections = {
    orders = {
      engine         = "postgres"
      host           = "orders.internal:5432"
      credential_ref = "secret/orders"
    }
    events = {
      engine            = "mongodb"
      host              = "events.internal:27017"
      agent_pool        = "pool-b"
      credential_source = ""
      audit_enabled     = false
    }
  }
  connection_passwords = {
    events = "hunter2"
  }
  api_keys = {
    deployer = {
      role          = "viewer"
      allowed_cidrs = ["10.0.0.0/8"]
      expires_in    = "720h"
    }
    reader = {
      role = "viewer"
    }
  }
}

run "connections_inherit_defaults" {
  command = apply

  assert {
    condition     = length(relay_connection.this) == 2
    error_message = "one connection per map entry"
  }

  assert {
    condition     = relay_connection.this["orders"].agent_pool == "pool-a" && relay_connection.this["orders"].credential_source == "vault"
    error_message = "unset fields take the defaults"
  }

  assert {
    condition     = relay_connection.this["events"].agent_pool == "pool-b" && relay_connection.this["events"].credential_source == ""
    error_message = "explicit values, including empty strings, override the defaults"
  }

  assert {
    condition     = relay_connection.this["events"].audit_enabled == false && relay_connection.this["orders"].audit_enabled == true
    error_message = "audit_enabled keeps an explicit false"
  }

  assert {
    condition     = relay_connection.this["orders"].password == null
    error_message = "a connection without an entry in connection_passwords sends no password"
  }

  assert {
    condition     = relay_connection.this["orders"].workspace_id == "ws-123"
    error_message = "connections are created in the module's workspace"
  }

  assert {
    condition     = output.workspace_id == "ws-123" && output.workspace_slug == "prod" && keys(output.connections) == ["events", "orders"]
    error_message = "outputs expose the workspace and every connection"
  }
}

run "no_connections" {
  command = apply

  variables {
    connections = {}
    api_keys    = {}
  }

  assert {
    condition     = length(relay_connection.this) == 0 && output.connections == {} && output.api_keys == {}
    error_message = "a workspace without connections or API keys is valid"
  }
}

run "api_keys" {
  command = apply

  assert {
    condition     = relay_api_key.this["deployer"].workspace_id == "ws-123" && relay_api_key.this["deployer"].name == "deployer"
    error_message = "API keys are created in the module's workspace, named by their map key"
  }

  assert {
    condition     = relay_api_key.this["reader"].allowed_cidrs == null && relay_api_key.this["reader"].expires_in == null
    error_message = "unset allowed_cidrs and expires_in are not sent"
  }

  assert {
    condition     = keys(output.api_keys) == ["deployer", "reader"] && output.api_keys["deployer"].id == "key-1"
    error_message = "outputs expose every API key"
  }

  assert {
    condition     = nonsensitive(output.api_key_secrets["deployer"]) == "rly_key_mock"
    error_message = "secrets are exposed through the sensitive output"
  }
}
