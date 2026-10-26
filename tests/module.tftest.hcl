mock_provider "relay" {
  mock_resource "relay_valkey_cluster" {
    defaults = {
      id            = "db-123"
      phase         = "running"
      endpoint_host = "sessions.db"
      endpoint_port = 6379
    }
  }
  mock_resource "relay_valkey_user" {
    defaults = {
      id                 = "db-123/app"
      generated_password = "generated"
    }
  }
}

variables {
  workspace_id   = "ws-1"
  name           = "sessions"
  engine_version = "9.1"
  size           = "RC20"
  node_count     = 2
  cloud          = "aws"
  region         = "us-east-1"
  users = {
    app       = { role = "readWrite" }
    reporting = { role = "readOnly", description = "dashboards" }
  }
  user_passwords = {
    reporting = "hunter2"
  }
}

run "size_preset_and_users" {
  command = apply

  assert {
    condition     = length(relay_valkey_cluster.this.nodes) == 1 && relay_valkey_cluster.this.nodes["primary"].count == 2
    error_message = "size builds one primary group with node_count nodes"
  }

  assert {
    condition     = relay_valkey_cluster.this.nodes["primary"].tier == "RC20" && relay_valkey_cluster.this.nodes["primary"].resources.storage == "8Gi"
    error_message = "size RC20 maps to catalog included storage"
  }

  assert {
    condition     = relay_valkey_cluster.this.mode == "replication" && relay_valkey_cluster.this.shards == null
    error_message = "the cluster defaults to replication mode without shards"
  }

  assert {
    condition     = relay_valkey_user.this["app"].generate_password && relay_valkey_user.this["app"].password == null
    error_message = "a user without a password gets a generated one"
  }

  assert {
    condition     = !relay_valkey_user.this["reporting"].generate_password && relay_valkey_user.this["reporting"].role == "readOnly"
    error_message = "a user with a password does not get a generated one"
  }

  assert {
    condition     = relay_valkey_user.this["reporting"].cluster_id == "db-123"
    error_message = "users are created on the module's cluster"
  }

  assert {
    condition     = output.cluster_id == "db-123" && output.endpoint.port == 6379 && output.usernames == ["app", "reporting"]
    error_message = "outputs expose the cluster and its users"
  }

  assert {
    condition     = keys(nonsensitive(output.generated_passwords)) == ["app"]
    error_message = "only generated passwords are output"
  }
}

run "cluster_mode_derives_the_count" {
  command = apply

  variables {
    mode               = "cluster"
    shards             = 3
    replicas_per_shard = 1
    users              = {}
    user_passwords     = {}
  }

  assert {
    condition     = relay_valkey_cluster.this.nodes["primary"].count == 6
    error_message = "cluster mode sizes the group at shards * (1 + replicas_per_shard), ignoring node_count"
  }

  assert {
    condition     = relay_valkey_cluster.this.shards == 3 && relay_valkey_cluster.this.replicas_per_shard == 1
    error_message = "shards and replicas pass through"
  }
}

run "cluster_mode_without_replicas" {
  command = plan

  variables {
    mode           = "cluster"
    shards         = 4
    users          = {}
    user_passwords = {}
  }

  assert {
    condition     = relay_valkey_cluster.this.nodes["primary"].count == 4
    error_message = "omitted replicas_per_shard counts as zero"
  }
}

run "explicit_nodes" {
  command = apply

  variables {
    size   = null
    cloud  = null
    region = null
    nodes = {
      cache = {
        count  = 3
        cloud  = "gcp"
        region = "us-central1"
        tier   = "RC10"
        resources = {
          storage = "20Gi"
        }
      }
    }
    users          = {}
    user_passwords = {}
  }

  assert {
    condition     = relay_valkey_cluster.this.nodes["cache"].cloud == "gcp" && relay_valkey_cluster.this.nodes["cache"].count == 3 && relay_valkey_cluster.this.nodes["cache"].resources.storage == "20Gi"
    error_message = "explicit nodes pass through"
  }
}

run "parameters_pass_through" {
  command = apply

  variables {
    parameters     = { maxmemory-policy = "allkeys-lru" }
    users          = {}
    user_passwords = {}
  }

  assert {
    condition     = relay_valkey_cluster.this.parameters["maxmemory-policy"] == "allkeys-lru"
    error_message = "parameters pass through"
  }
}

run "rejects_size_and_nodes" {
  command = plan

  variables {
    nodes = {
      primary = {
        cloud     = "aws"
        region    = "us-east-1"
        tier      = "RC10"
        resources = { storage = "4Gi" }
      }
    }
  }

  expect_failures = [relay_valkey_cluster.this]
}

run "rejects_size_without_placement" {
  command = plan

  variables {
    region = null
  }

  expect_failures = [relay_valkey_cluster.this]
}

run "rejects_unknown_mode" {
  command = plan

  variables {
    mode = "sentinel"
  }

  expect_failures = [var.mode]
}

run "rejects_unknown_size" {
  command = plan

  variables {
    size = "R30"
  }

  expect_failures = [var.size]
}
