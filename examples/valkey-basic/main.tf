provider "relay" {}

data "relay_workspace" "prod" {
  name = "prod"
}

module "sessions" {
  source = "../.."

  workspace_id   = data.relay_workspace.prod.id
  name           = "sessions"
  engine_version = "9.1"
  size           = "RC20"
  node_count     = 2
  cloud          = "aws"
  region         = "us-east-1"

  parameters = {
    maxmemory-policy = "allkeys-lru"
  }

  users = {
    app = { role = "readWrite" }
  }
}

output "app_password" {
  value     = module.sessions.generated_passwords["app"]
  sensitive = true
}
