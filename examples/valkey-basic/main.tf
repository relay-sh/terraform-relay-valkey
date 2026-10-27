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

  backup_schedule = {
    snapshot_time = { hour = 4, minute = 0 }
    max_backups   = 7
  }

  users = {
    app = { role = "readWrite" }
  }
}

output "app_password" {
  value     = module.sessions.generated_passwords["app"]
  sensitive = true
}
