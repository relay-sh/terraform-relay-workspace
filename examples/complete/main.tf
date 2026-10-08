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
      redact_enabled    = false
    }
  }

  connection_passwords = {
    legacy = var.legacy_password
  }

  api_keys = {
    deployer = {
      role          = "admin"
      allowed_cidrs = ["203.0.113.0/24"]
      expires_in    = "2160h"
    }
  }
}

output "connections" {
  value = module.workspace.connections
}

output "deployer_api_key" {
  value     = module.workspace.api_key_secrets["deployer"]
  sensitive = true
}
