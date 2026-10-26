resource "relay_valkey_cluster" "this" {
  workspace_id       = var.workspace_id
  name               = var.name
  version            = var.engine_version
  mode               = var.mode
  shards             = var.shards
  replicas_per_shard = var.replicas_per_shard
  nodes              = local.nodes
  parameters         = var.parameters

  keep_backups_on_destroy = var.keep_backups_on_destroy

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {
    precondition {
      condition     = (var.size == null) != (var.nodes == null)
      error_message = "Set exactly one of size or nodes."
    }
    precondition {
      condition     = var.nodes != null || (var.cloud != null && var.region != null)
      error_message = "cloud and region are required when using size."
    }
  }
}

resource "relay_valkey_user" "this" {
  for_each = var.users

  workspace_id      = var.workspace_id
  cluster_id        = relay_valkey_cluster.this.id
  username          = each.key
  role              = each.value.role
  password          = contains(local.password_users, each.key) ? var.user_passwords[each.key] : null
  generate_password = !contains(local.password_users, each.key)
  description       = each.value.description
  expires_at        = each.value.expires_at
}
