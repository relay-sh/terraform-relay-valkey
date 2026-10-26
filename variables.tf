variable "workspace_id" {
  description = "Workspace the cluster belongs to."
  type        = string
}

variable "name" {
  description = "Cluster name, unique in the workspace. Changing it replaces the cluster."
  type        = string
}

variable "engine_version" {
  description = "Valkey version, for example 9.1. Omit it and the platform picks one. Upgrades go through Relay's upgrade flow, not this variable."
  type        = string
  default     = null
}

variable "mode" {
  description = "replication runs one primary and its replicas; cluster shards the keyspace. Changing it replaces the cluster."
  type        = string
  default     = "replication"

  validation {
    condition     = contains(["replication", "cluster"], var.mode)
    error_message = "mode must be replication or cluster."
  }
}

variable "shards" {
  description = "Primaries the keyspace is split across in cluster mode, 3-100."
  type        = number
  default     = null
}

variable "replicas_per_shard" {
  description = "Replicas behind each shard's primary in cluster mode, 0-4."
  type        = number
  default     = null
}

variable "size" {
  description = "Relay Cache catalog tier (RC5–RC80). CPU and memory come from the catalog; included storage is the default volume. Set either size or nodes."
  type        = string
  default     = null

  validation {
    condition     = var.size == null || contains(["RC5", "RC10", "RC20", "RC30", "RC40", "RC50", "RC60", "RC80"], coalesce(var.size, "RC5"))
    error_message = "size must be a catalog name: RC5, RC10, RC20, RC30, RC40, RC50, RC60, or RC80."
  }
}

variable "node_count" {
  description = "Nodes when using size in replication mode: one primary and node_count - 1 replicas. In cluster mode the count is shards * (1 + replicas_per_shard)."
  type        = number
  default     = 1
}

variable "cloud" {
  description = "Cloud for the node group when using size, for example aws."
  type        = string
  default     = null
}

variable "region" {
  description = "Region for the node group when using size."
  type        = string
  default     = null
}

variable "nodes" {
  description = "The cluster's single node group, keyed by group name, when size is not enough: extra storage or a group name of your own. Renaming the group replaces the cluster."
  type = map(object({
    count  = optional(number, 1)
    cloud  = string
    region = string
    tier   = string
    resources = object({
      storage = string
      storage_autoscale = optional(object({
        enabled           = bool
        threshold_percent = optional(number)
        increase_percent  = optional(number)
        max_storage       = optional(string)
      }))
    })
  }))
  default = null
}

variable "storage_autoscale" {
  description = "Grows the node group's volume past its included storage, up to max_storage, when using size. With nodes, set it under resources."
  type = object({
    enabled           = bool
    threshold_percent = optional(number)
    increase_percent  = optional(number)
    max_storage       = optional(string)
  })
  default = null
}

variable "parameters" {
  description = "Valkey settings, for example maxmemory-policy. An empty map resets them; null leaves them unmanaged."
  type        = map(string)
  default     = null
}

variable "keep_backups_on_destroy" {
  description = "Keep the cluster's backups when it is destroyed."
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Create, update and delete timeouts, for example 45m."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}

variable "users" {
  description = "Valkey ACL users keyed by username. A user without an entry in user_passwords gets a generated password."
  type = map(object({
    role        = string
    description = optional(string)
    expires_at  = optional(string)
  }))
  default = {}
}

variable "user_passwords" {
  description = "Passwords keyed by username, for users that should not get a generated one."
  type        = map(string)
  default     = {}
  sensitive   = true
}
