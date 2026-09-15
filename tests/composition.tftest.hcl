mock_provider "relay" {
  mock_resource "relay_workspace" {
    defaults = {
      id   = "ws-123"
      slug = "prod"
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
      kind              = "service"
      credential_source = ""
      audit_enabled     = false
    }
  }
  connection_passwords = {
    events = "hunter2"
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
    condition     = relay_connection.this["events"].kind == "service" && relay_connection.this["orders"].kind == "interactive"
    error_message = "kind falls back to interactive"
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
  }

  assert {
    condition     = length(relay_connection.this) == 0 && output.connections == {}
    error_message = "a workspace without connections is valid"
  }
}

run "rejects_unknown_kind" {
  command = plan

  variables {
    connection_defaults = {
      kind = "batch"
    }
  }

  expect_failures = [var.connection_defaults]
}

run "rejects_unknown_connection_kind" {
  command = plan

  variables {
    connections = {
      bad = {
        engine = "postgres"
        host   = "x:5432"
        kind   = "batch"
      }
    }
  }

  expect_failures = [var.connections]
}
