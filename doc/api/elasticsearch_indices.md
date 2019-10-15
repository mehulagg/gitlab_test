# Elasticsearch Indices API **(STARTER)**

In order to interact with Elasticsearch indices endpoints, you need to authenticate yourself as an admin.

Please refer to the documentation on the [Elasticsearch integration](../integration/elasticsearch.md) for more details.

## Retrieve information about all Elasticsearch indices

```
GET /elasticsearch_indices
```

```bash
curl --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices
```

Example response:

```json
[
  {
    "id": 1,
    "name": "gitlab-production-v12p1-3d97a152",
    "friendly_name": "GitLab Production",
    "version": "V12p1",
    "shards": 5,
    "replicas": 1,
    "urls": "https://elasticsearch-host:9200",
    "aws": false,
    "aws_region": null,
    "aws_access_key": null,
    "aws_secret_access_key": null,
    "active_search_source": true
  },
  {
    "id": 2,
    "name": "gitlab-production-v12p1-a223b368",
    "friendly_name": "Second index",
    "version": "V12p1",
    "shards": 5,
    "replicas": 1,
    "urls": "https://elasticsearch-host:9200",
    "aws": false,
    "aws_region": null,
    "aws_access_key": null,
    "aws_secret_access_key": null,
    "active_search_source": false
  }
]
```

## Retrieve information about a specific Elasticsearch index

```
GET /elasticsearch_indices/:id
```

| Attribute | Type    | Required  | Description         |
| --------- | ------- | --------- | ------------------- |
| `id`      | integer | yes       | The ID of the index |

```bash
curl --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices/1
```

Example response:

```json
{
  "id": 1,
  "name": "gitlab-production-v12p1-3d97a152",
  "friendly_name": "GitLab Production",
  "version": "V12p1",
  "shards": 5,
  "replicas": 1,
  "urls": "https://elasticsearch-host:9200",
  "aws": false,
  "aws_region": null,
  "aws_access_key": null,
  "aws_secret_access_key": null,
  "active_search_source": true
}
```

## Create a new Elasticsearch index

Creates a new configuration for an Elasticsearch index, and creates the index in the specified Elasticsearch cluster.

```
POST /elasticsearch_indices
```

| Attribute               | Type    | Required               | Description                                        |
| ----------------------- | ------- | ---------------------- | -------------------------------------------------- |
| `friendly_name`         | string  | yes                    | The user-visible name of the index.                |
| `urls`                  | string  | yes                    | The URL(s) to use for connecting to Elasticsearch. |
| `shards`                | integer | no                     | The number of shards in the index.                 |
| `replicas`              | integer | no                     | The number of replicas in the index.               |
| `aws`                   | boolean | no                     | Use AWS hosted Elasticsearch.                      |
| `aws_region`            | string  | yes if `aws` is `true` | The AWS region.                                    |
| `aws_access_key`        | string  | no                     | The AWS access key.                                |
| `aws_secret_access_key` | string  | no                     | The AWS secret access key.                         |

```bash
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices?friendly_name=New+index&urls=https://elasticsearch-host1:9200,https://elasticsearch-host2:9200
```

Example response:

```json
{
  "id": 1,
  "name": "gitlab-production-v12p1-3d97a152",
  "friendly_name": "New index",
  "version": "V12p1",
  "shards": 5,
  "replicas": 1,
  "urls": "https://elasticsearch-host1:9200, https://elasticsearch-host2:9200",
  "aws": false,
  "aws_region": null,
  "aws_access_key": null,
  "aws_secret_access_key": null,
  "active_search_source": false
}
```

Returns:

- `201 Created` if the index was successfully created.
- `400 Bad Request` if the index couldn't be created, with an error message explaining the reason.

## Edit an Elasticsearch index

Edits the configuration for an existing Elasticsearch index.

```
PUT /elasticsearch_indices/:id
```

| Attribute               | Type    | Required | Description                                        |
| ----------------------- | ------- | -------- | -------------------------------------------------- |
| `id`                    | integer | yes      | The ID of the index.                               |
| `friendly_name`         | string  | no       | The user-visible name of the index.                |
| `urls`                  | string  | no       | The URL(s) to use for connecting to Elasticsearch. |
| `shards`                | integer | no       | The number of shards in the index.                 |
| `replicas`              | integer | no       | The number of replicas in the index.               |
| `aws`                   | boolean | no       | Use AWS hosted Elasticsearch.                      |
| `aws_region`            | string  | no       | The AWS region.                                    |
| `aws_access_key`        | string  | no       | The AWS access key.                                |
| `aws_secret_access_key` | string  | no       | The AWS secret access key.                         |

```bash
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices/1?friendly_name=New+name
```

Example response:

```json
{
  "id": 1,
  "name": "gitlab-production-v12p1-3d97a152",
  "friendly_name": "New name",
  "version": "V12p1",
  "shards": 5,
  "replicas": 1,
  "urls": "https://elasticsearch-host1:9200, https://elasticsearch-host2:9200",
  "aws": false,
  "aws_region": null,
  "aws_access_key": null,
  "aws_secret_access_key": null,
  "active_search_source": false
}
```

Returns:

- `200 OK` if the index was successfully updated.
- `400 Bad Request` if the index couldn't be updated, with an error message explaining the reason.

## Delete an Elasticsearch index

Deletes the configuration for an existing Elasticsearch index, and deletes the index in the configured Elasticsearch cluster.

```
DELETE /elasticsearch_indices/:id
```

| Attribute | Type    | Required  | Description          |
| --------- | ------- | --------- | -------------------- |
| `id`      | integer | yes       | The ID of the index. |

```bash
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices/1
```

Returns:

- `204 No Content` if the index was successfully deleted.
- `400 Bad Request` if the index couldn't be deleted, with an error message explaining the reason.

## Change the active Elasticsearch source

Changes the specified Elasticsearch index to be the active search source.

```
POST /elasticsearch_indices/mark_active_search_source/:id
```

| Attribute | Type    | Required  | Description          |
| --------- | ------- | --------- | -------------------- |
| `id`      | integer | yes       | The ID of the index. |

```bash
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices/mark_active_search_source/1
```

Returns:

- `204 No Content` if the active search source was successfully changed.
- `400 Bad Request` if the active search source couldn't be changed, with an error message explaining the reason.

## Toggle Elasticsearch indexing

Enables or disables indexing to Elasticsearch when data in GitLab changes.

```
POST /elasticsearch_indices/toggle_indexing
```

| Attribute  | Type    | Required  | Description                            |
| ---------- | ------- | --------- | -------------------------------------- |
| `indexing` | boolean | yes       | Whether to enable or disable indexing. |

```bash
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices/toggle_indexing?indexing=true
```

Returns:

- `204 No Content` if the indexing setting was successfully saved.
- `400 Bad Request` if the indexing setting couldn't be saved, with an error message explaining the reason.

## Start a reindexing job for Elasticsearch

This starts a background job to index all data in GitLab, and also enables indexing if necessary.

```
POST /elasticsearch_indices/reindex
```

```bash
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" https://primary.example.com/api/v4/elasticsearch_indices/reindex
```

Returns:

- `204 No Content` if the indexing job was successfully queued.
- `400 Bad Request` if the indexing setting couldn't be saved, with an error message explaining the reason.
