## 0.0.3 (November 1, 2026)

ENHANCEMENTS:

* `restore` creates the cluster from another cluster's backups, the latest one or a point in time with `target_time` in `replication` mode; it needs provider 0.0.5 or later.

## 0.0.2 (November 1, 2026)

ENHANCEMENTS:

* `backup_schedule.pitr_window_days` turns on point-in-time restore, 1-35 days, in `replication` mode only; it needs provider 0.0.4 or later.

## 0.0.1 (October 28, 2026)

FEATURES:

* Managed Valkey cluster with Relay Cache size presets (`RC5`–`RC80`), replication or cluster mode, and ACL users.
* `storage_autoscale` grows the volume past its storage, for the size preset or under `nodes`.
* `backup_schedule` manages the cluster's backup schedule through `relay_backup_schedule`; `null` keeps the platform default.
