provider "relay" {}

provider "aws" {
  region = "us-east-1"
}

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

  ip_access_list = {
    "203.0.113.0/24" = "Office VPN"
  }

  private_endpoint_services = {
    use1 = { region = "us-east-1" }
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

resource "aws_vpc_endpoint" "relay" {
  vpc_id             = var.vpc_id
  service_name       = module.workspace.private_endpoint_services["use1"].endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = [var.security_group_id]
}

resource "relay_private_endpoint" "app" {
  workspace_id    = module.workspace.workspace_id
  service_id      = module.workspace.private_endpoint_services["use1"].id
  vpc_endpoint_id = aws_vpc_endpoint.relay.id
}

output "connections" {
  value = module.workspace.connections
}

output "deployer_api_key" {
  value     = module.workspace.api_key_secrets["deployer"]
  sensitive = true
}
