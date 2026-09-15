provider "relay" {
  endpoint = "api.staging.userelay.sh:443"
  org_id   = "00000000-0000-0000-0000-000000000000"
}

module "workspace" {
  source = "../.."

  name        = "prod"
  description = "Production"

  connections = {
    orders = {
      engine         = "postgres"
      host           = "orders.internal:5432"
      user           = "app"
      database       = "orders"
      credential_ref = "secret/data/orders#password"
    }
  }
}

output "workspace_id" {
  value = module.workspace.workspace_id
}
