provider "relay" {}

variable "legacy_password" {
  type      = string
  sensitive = true
}

module "workspace" {
  source = "../.."

  name        = "payments"
  description = "Payments team"

  connection_defaults = {
    agent_pool        = "payments"
    credential_source = "vault-prod"
    redact_enabled    = true
  }

  connections = {
    ledger = {
      engine         = "postgres"
      host           = "ledger.internal:5432"
      user           = "ledger"
      database       = "ledger"
      credential_ref = "secret/data/ledger#password"
      redact_rules = [
        { column_pattern = "card_number", strategy = "partial", partial_show = 4 },
        { column_pattern = "email", strategy = "hash" },
      ]
    }
    legacy = {
      engine            = "mysql"
      host              = "legacy.internal:3306"
      user              = "report"
      credential_source = ""
      kind              = "service"
      redact_enabled    = false
    }
  }

  connection_passwords = {
    legacy = var.legacy_password
  }
}

output "connections" {
  value = module.workspace.connections
}
