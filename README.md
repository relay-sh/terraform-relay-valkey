# terraform-relay-valkey

Creates a Relay managed Valkey cluster and its ACL users. A `size` catalog
tier covers the common shapes; `nodes` takes over when you need extra storage
or a group name of your own.

```hcl
module "sessions" {
  source  = "relay-sh/valkey/relay"
  version = "~> 0.0.1"

  workspace_id   = module.workspace.workspace_id
  name           = "sessions"
  engine_version = "9.1"
  size           = "RC20"
  node_count     = 2
  cloud          = "aws"
  region         = "us-east-1"

  users = {
    app = { role = "readWrite" }
  }
}
```

| Size | CPU  | Memory | Included storage |
| ---- | ---- | ------ | ---------------- |
| RC5  | 250m | 512Mi  | 1Gi              |
| RC10 | 500m | 2Gi    | 4Gi              |
| RC20 | 1    | 4Gi    | 8Gi              |
| RC30 | 1    | 8Gi    | 16Gi             |
| RC40 | 2    | 13.5Gi | 28Gi             |
| RC50 | 4    | 28Gi   | 56Gi             |
| RC60 | 8    | 58Gi   | 116Gi            |
| RC80 | 16   | 118Gi  | 236Gi            |

CPU and memory are derived from `size` / `nodes.*.tier`. An unknown name is
rejected. Storage can grow past the included amount via `nodes`, or on its own
with `storage_autoscale`, up to its `max_storage`.

`mode = "cluster"` shards the keyspace across `shards` primaries, each with
`replicas_per_shard` replicas. With `size`, the node count is derived as
`shards * (1 + replicas_per_shard)` and `node_count` is ignored; with `nodes`,
`count` must match it.

Users get a generated password, exposed once in the sensitive
`generated_passwords` output and kept in state, unless `user_passwords` has an
entry for them. A user holds one role (`readOnly`, `readWrite` or `admin`)
over the whole keyspace.

Changing `name` or `mode` replaces the cluster and its data. Version upgrades
go through Relay's upgrade flow; a plan that changes `engine_version` fails
instead of replacing the cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_relay"></a> [relay](#requirement\_relay) | ~> 0.0.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_relay"></a> [relay](#provider\_relay) | ~> 0.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [relay_valkey_cluster.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/valkey_cluster) | resource |
| [relay_valkey_user.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/valkey_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Cluster name, unique in the workspace. Changing it replaces the cluster. | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Workspace the cluster belongs to. | `string` | n/a | yes |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Cloud for the node group when using size, for example aws. | `string` | `null` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Valkey version, for example 9.1. Omit it and the platform picks one. Upgrades go through Relay's upgrade flow, not this variable. | `string` | `null` | no |
| <a name="input_keep_backups_on_destroy"></a> [keep\_backups\_on\_destroy](#input\_keep\_backups\_on\_destroy) | Keep the cluster's backups when it is destroyed. | `bool` | `false` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | replication runs one primary and its replicas; cluster shards the keyspace. Changing it replaces the cluster. | `string` | `"replication"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Nodes when using size in replication mode: one primary and node\_count - 1 replicas. In cluster mode the count is shards * (1 + replicas\_per\_shard). | `number` | `1` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | The cluster's single node group, keyed by group name, when size is not enough: extra storage or a group name of your own. Renaming the group replaces the cluster. | <pre>map(object({<br/>    count  = optional(number, 1)<br/>    cloud  = string<br/>    region = string<br/>    tier   = string<br/>    resources = object({<br/>      storage = string<br/>      storage_autoscale = optional(object({<br/>        enabled           = bool<br/>        threshold_percent = optional(number)<br/>        increase_percent  = optional(number)<br/>        max_storage       = optional(string)<br/>      }))<br/>    })<br/>  }))</pre> | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Valkey settings, for example maxmemory-policy. An empty map resets them; null leaves them unmanaged. | `map(string)` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the node group when using size. | `string` | `null` | no |
| <a name="input_replicas_per_shard"></a> [replicas\_per\_shard](#input\_replicas\_per\_shard) | Replicas behind each shard's primary in cluster mode, 0-4. | `number` | `null` | no |
| <a name="input_shards"></a> [shards](#input\_shards) | Primaries the keyspace is split across in cluster mode, 3-100. | `number` | `null` | no |
| <a name="input_size"></a> [size](#input\_size) | Relay Cache catalog tier (RC5–RC80). CPU and memory come from the catalog; included storage is the default volume. Set either size or nodes. | `string` | `null` | no |
| <a name="input_storage_autoscale"></a> [storage\_autoscale](#input\_storage\_autoscale) | Grows the node group's volume past its included storage, up to max\_storage, when using size. With nodes, set it under resources. | <pre>object({<br/>    enabled           = bool<br/>    threshold_percent = optional(number)<br/>    increase_percent  = optional(number)<br/>    max_storage       = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update and delete timeouts, for example 45m. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_user_passwords"></a> [user\_passwords](#input\_user\_passwords) | Passwords keyed by username, for users that should not get a generated one. | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | Valkey ACL users keyed by username. A user without an entry in user\_passwords gets a generated password. | <pre>map(object({<br/>    role        = string<br/>    description = optional(string)<br/>    expires_at  = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Cluster ID. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Primary endpoint. |
| <a name="output_generated_passwords"></a> [generated\_passwords](#output\_generated\_passwords) | Generated passwords by username. Not recoverable from the API. |
| <a name="output_phase"></a> [phase](#output\_phase) | Cluster phase after the last apply. |
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | Private endpoints by role. |
| <a name="output_public_endpoints"></a> [public\_endpoints](#output\_public\_endpoints) | Public endpoints by role. |
| <a name="output_usernames"></a> [usernames](#output\_usernames) | Created usernames. |
<!-- END_TF_DOCS -->
