provider "relay" {}

data "relay_workspace" "prod" {
  name = "prod"
}

module "sessions" {
  source = "../.."

  workspace_id   = data.relay_workspace.prod.id
  name           = "sessions"
  engine_version = "9.1"

  nodes = {
    cache = {
      count  = 2
      cloud  = "aws"
      region = "us-east-1"
      tier   = "RC20"
      autoscaling = {
        enabled  = true
        min_tier = "RC10"
        max_tier = "RC40"
        rules = [
          { metric = "valkey.memory", scale_up_above = 85, scale_down_below = 40 },
          { metric = "valkey.ops", scale_up_above = 50000, scale_down_below = 10000 },
        ]
        scale_up_window = "5m"
      }
    }
  }
}

output "cluster_id" {
  value = module.sessions.cluster_id
}
