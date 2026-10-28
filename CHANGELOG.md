## 0.0.1 (October 28, 2026)

FEATURES:

* Managed Valkey cluster with Relay Cache size presets (`RC5`–`RC80`), replication or cluster mode, and ACL users.
* `storage_autoscale` grows the volume past its storage, for the size preset or under `nodes`.
* `backup_schedule` manages the cluster's backup schedule through `relay_backup_schedule`; `null` keeps the platform default.
