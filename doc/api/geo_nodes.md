# Geo Nodes API

In order to interact with Geo node endpoints, you need to authenticate yourself
as an admin.

## Retrieve configuration about all Geo nodes

```
GET /geo_nodes
```

```bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/geo_nodes
```

Example response:

```json
[
  {
    "id": 1,
    "url": "https://primary.example.com/",
    "primary": true,
    "enabled": true,
    "current": true,
    "files_max_capacity": 10,
    "repos_max_capacity": 25,
    "clone_protocol": "http"
  },
  {
    "id": 2,
    "url": "https://secondary.example.com/",
    "primary": false,
    "enabled": true,
    "current": false,
    "files_max_capacity": 10,
    "repos_max_capacity": 25,
    "clone_protocol": "http"
  }
]
```

## Retrieve configuration about a specific Geo node

```
GET /geo_nodes/:id
```

```bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/geo_nodes/1
```

Example response:

```json
{
  "id": 1,
  "url": "https://primary.example.com/",
  "primary": true,
  "enabled": true,
  "current": true,
  "files_max_capacity": 10,
  "repos_max_capacity": 25,
  "clone_protocol": "http"
}
```

## Retrieve status about all secondary Geo nodes

```
GET /geo_nodes/status
```

```bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/geo_nodes/status
```

Example response:

```json
[
  {
    "geo_node_id": 2,
    "healthy": true,
    "health": "Healthy",
    "health_status": "Healthy",
    "missing_oauth_application": false,
    "attachments_count": 1,
    "attachments_synced_count": 1,
    "attachments_failed_count": 0,
    "attachments_synced_in_percentage": "100.00%",
    "db_replication_lag_seconds": 0,
    "lfs_objects_count": 0,
    "lfs_objects_synced_count": 0,
    "lfs_objects_failed_count": 0,
    "lfs_objects_synced_in_percentage": "0.00%",
    "job_artifacts_count": 2,
    "job_artifacts_synced_count": 1,
    "job_artifacts_failed_count": 1,
    "job_artifacts_synced_in_percentage": "50.00%",
    "repositories_count": 41,
    "repositories_failed_count": 1,
    "repositories_synced_count": 40,
    "repositories_synced_in_percentage": "97.56%",
    "wikis_count": 41,
    "wikis_failed_count": 0,
    "wikis_synced_count": 41,
    "wikis_synced_in_percentage": "100.00%",
    "last_event_id": 23,
    "last_event_timestamp": 1509681166,
    "cursor_last_event_id": 23,
    "cursor_last_event_timestamp": 1509681166,
    "last_successful_status_check_timestamp": 1510125024,
    "version": "10.3.0",
    "revision": "33d33a096a"
  }
]
```

## Retrieve status about a specific secondary Geo node

```
GET /geo_nodes/:id/status
```

```bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/geo_nodes/2/status
```

Example response:

```json
{
  "geo_node_id": 2,
  "healthy": true,
  "health": "Healthy",
  "health_status": "Healthy",
  "missing_oauth_application": false,
  "attachments_count": 1,
  "attachments_synced_count": 1,
  "attachments_failed_count": 0,
  "attachments_synced_in_percentage": "100.00%",
  "db_replication_lag_seconds": 0,
  "lfs_objects_count": 0,
  "lfs_objects_synced_count": 0,
  "lfs_objects_failed_count": 0,
  "lfs_objects_synced_in_percentage": "0.00%",
  "job_artifacts_count": 2,
  "job_artifacts_synced_count": 1,
  "job_artifacts_failed_count": 1,
  "job_artifacts_synced_in_percentage": "50.00%",
  "repositories_count": 41,
  "repositories_failed_count": 1,
  "repositories_synced_count": 40,
  "repositories_synced_in_percentage": "97.56%",
  "last_event_id": 23,
  "last_event_timestamp": 1509681166,
  "cursor_last_event_id": 23,
  "cursor_last_event_timestamp": 1509681166,
  "last_successful_status_check_timestamp": 1510125268,
  "version": "10.3.0",
  "revision": "33d33a096a"
}
```

## Retrieve project sync failures ocurred on the current node


```
GET /geo_nodes/current/failures
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `type` | string | no | Type of failure (`repository`/`wiki`) |

This endpoint uses [Pagination](README.md#pagination).

```bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v4/geo_nodes/current/failures
```

Example response:

```json
[
  {
    "project_id": 3,
    "last_repository_synced_at": "2017-10-31 14:25:55 UTC",
    "last_repository_successful_sync_at": "2017-10-31 14:26:04 UTC",
    "last_wiki_synced_at": "2017-10-31 14:26:04 UTC",
    "last_wiki_successful_sync_at": "2017-10-31 14:26:11 UTC",
    "repository_retry_count": null,
    "wiki_retry_count": 1,
    "last_repository_sync_failure": null,
    "last_wiki_sync_failure": "Error syncing Wiki repository"
  }
]
```
