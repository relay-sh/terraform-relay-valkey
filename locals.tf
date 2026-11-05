locals {
  included_storage = {
    RC5  = "1Gi"
    RC10 = "4Gi"
    RC20 = "8Gi"
    RC30 = "16Gi"
    RC40 = "28Gi"
    RC50 = "56Gi"
    RC60 = "116Gi"
    RC80 = "236Gi"
  }

  sized_count = var.mode == "cluster" && var.shards != null ? var.shards * (1 + coalesce(var.replicas_per_shard, 0)) : var.node_count

  nodes = var.nodes != null ? { for name, n in var.nodes : name => merge(n, { resources = {} }) } : {
    primary = {
      count     = local.sized_count
      cloud     = var.cloud
      region    = var.region
      tier      = var.size
      resources = {}
    }
  }

  storage_size = coalesce(var.storage_size, "${max([for n in values(local.nodes) : tonumber(trimsuffix(local.included_storage[n.tier], "Gi"))]...)}Gi")

  password_users = toset(nonsensitive(keys(var.user_passwords)))
}
