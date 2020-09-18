---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
type: howto
---

# Geo data types support **(PREMIUM ONLY)**

A Geo data type is a specific class of data that is required by one or more GitLab features to
store relevant information.

To replicate data produced by these features with Geo, we use several strategies to access, transfer, and verify them.

## Data types

We currently distinguish between three different data types:

- [Git repositories](#git-repositories)
- [Blobs](#blobs)
- [Database](#database)

See the list below of each feature or component we replicate, its corresponding data type, replication, and
verification methods:

| Type     | Feature / component                           | Replication method                    | Verification method    |
|:---------|:----------------------------------------------|:--------------------------------------|:-----------------------|
| Database | Application data in PostgreSQL                | Native                                | Native                 |
| Database | Redis                                         | _N/A_ (*1*)                           | _N/A_                  |
| Database | Elasticsearch                                 | Native                                | Native                 |
| Database | Personal snippets                             | PostgreSQL Replication                | PostgreSQL Replication |
| Database | Project snippets                              | PostgreSQL Replication                | PostgreSQL Replication |
| Database | SSH public keys                               | PostgreSQL Replication                | PostgreSQL Replication |
| Git      | Project repository                            | Geo with Gitaly                       | Gitaly Checksum        |
| Git      | Project wiki repository                       | Geo with Gitaly                       | Gitaly Checksum        |
| Git      | Project designs repository                    | Geo with Gitaly                       | Gitaly Checksum        |
| Git      | Object pools for forked project deduplication | Geo with Gitaly                       | _Not implemented_      |
| Blobs    | User uploads _(filesystem)_                   | Geo with API                          | _Not implemented_      |
| Blobs    | User uploads _(object storage)_               | Geo with API/Managed (*2*)            | _Not implemented_      |
| Blobs    | LFS objects _(filesystem)_                    | Geo with API                          | _Not implemented_      |
| Blobs    | LFS objects _(object storage)_                | Geo with API/Managed (*2*)            | _Not implemented_      |
| Blobs    | CI job artifacts _(filesystem)_               | Geo with API                          | _Not implemented_      |
| Blobs    | CI job artifacts _(object storage)_           | Geo with API/Managed (*2*)            | _Not implemented_      |
| Blobs    | Archived CI build traces _(filesystem)_       | Geo with API                          | _Not implemented_      |
| Blobs    | Archived CI build traces _(object storage)_   | Geo with API/Managed (*2*)            | _Not implemented_      |
| Blobs    | Container registry _(filesystem)_             | Geo with API/Docker API               | _Not implemented_      |
| Blobs    | Container registry _(object storage)_         | Geo with API/Managed/Docker API (*2*) | _Not implemented_      |
| Blobs    | Package registry _(filesystem)_               | Geo with API                          | _Not implemented_      |
| Blobs    | Package registry _(object storage)_           | Geo with API/Managed (*2*)            | _Not implemented_      |
| Blobs    | Terraform State _(filesystem)_                | Geo with API                          | _Not implemented_      |
| Blobs    | Terraform State _(object storage)_            | Geo with API/Managed (*2*)            | _Not implemented_      |
| Blobs    | Versioned Terraform State _(filesystem)_      | Geo with API                          | _Not implemented_      |
| Blobs    | Versioned Terraform State _(object storage)_  | Geo with API/Managed (*2*)            | _Not implemented_      |

- (*1*): Redis replication can be used as part of HA with Redis sentinel. It's not used between Geo nodes.
- (*2*): Object storage replication can be performed by Geo or by your object storage provider/appliance
         native replication feature.

### Git repositories

A GitLab instance can have one or more repository shards. Each shard has a Gitaly instance that
is responsible for allowing access and operations on the locally stored Git repositories. It can run
on a machine with a single disk, multiple disks mounted as a single mount-point (like with a RAID array),
or using LVM.

It requires no special filesystem and can work with NFS or a mounted Storage Appliance (there may be
performance limitations when using a remote filesystem).

Communication is done via Gitaly's own gRPC API. There are three possible ways of synchronization:

- Using regular Git clone/fetch from one Geo node to another (with special authentication).
- Using repository snapshots (for when the first method fails or repository is corrupt).
- Manual trigger from the Admin UI (a combination of both of the above).

Each project can have at most 3 different repositories:

- A project repository, where the source code is stored.
- A wiki repository, where the wiki content is stored.
- A design repository, where design artifacts are indexed (assets are actually in LFS).

They all live in the same shard and share the same base name with a `-wiki` and `-design` suffix
for Wiki and Design Repository cases.

### Blobs

GitLab stores files and blobs such as Issue attachments or LFS objects into either:

- The filesystem in a specific location.
- An [Object Storage](../../object_storage.md) solution. Object Storage solutions can be:
  - Cloud based like Amazon S3 Google Cloud Storage.
  - Hosted by you (like MinIO).
  - A Storage Appliance that exposes an Object Storage-compatible API.

When using the filesystem store instead of Object Storage, you need to use network mounted filesystems
to run GitLab when using more than one server.

With respect to replication and verification:

- We transfer files and blobs using an internal API request.
- With Object Storage, you can either:
  - Use a cloud provider replication functionality.
  - Have GitLab replicate it for you.

### Database

GitLab relies on data stored in multiple databases, for different use-cases.
PostgreSQL is the single point of truth for user-generated content in the Web interface, like issues content, comments
as well as permissions and credentials.

PostgreSQL can also hold some level of cached data like HTML rendered Markdown, cached merge-requests diff (this can
also be configured to be offloaded to object storage).

We use PostgreSQL's own replication functionality to replicate data from the **primary** to **secondary** nodes.

We use Redis both as a cache store and to hold persistent data for our background jobs system. Because both
use-cases has data that are exclusive to the same Geo node, we don't replicate it between nodes.

Elasticsearch is an optional database, that can enable advanced searching capabilities, like improved Global Search
in both source-code level and user generated content in Issues / Merge-Requests and discussions. Currently it's not
supported in Geo.

## Limitations on replication/verification

The following table lists the GitLab features along with their replication
and verification status on a **secondary** node.

You can keep track of the progress to implement the missing items in
these epics/issues:

- [Unreplicated Data Types](https://gitlab.com/groups/gitlab-org/-/epics/893)
- [Verify all replicated data](https://gitlab.com/groups/gitlab-org/-/epics/1430)

### Replicated data types behind a feature flag

The replication for some data types is behind a corresponding feature flag:

> - They're deployed behind a feature flag, enabled by default.
> - They're enabled on GitLab.com.
> - They can't be enabled or disabled per-project.
> - They are recommended for production use.
> - For GitLab self-managed instances, GitLab administrators can opt to [disable them](#enable-or-disable-replication-for-some-data-types). **(CORE ONLY)**

#### Enable or disable replication (for some data types) **(CORE ONLY)**

Replication for some data types are released behind feature flags that are **enabled by default**.
[GitLab administrators with access to the GitLab Rails console](../../feature_flags.md) can opt to disable it for your instance. You can find feature flag names of each of those data types in the notes column of the table below.

To disable, such as for package file replication:

```ruby
Feature.disable(:geo_package_file_replication)
```

To enable, such as for package file replication:

```ruby
Feature.enable(:geo_package_file_replication)
```

DANGER: **Danger:**
Features not on this list, or with **No** in the **Replicated** column,
are not replicated on the **secondary** node. Failing over without manually
replicating data from those features will cause the data to be **lost**.
If you wish to use those features on a **secondary** node, or to execute a failover
successfully, you must replicate their data using some other means.

| Feature                                                                                               | Replicated (added in GitLab version)                         | Verified (added in GitLab version)                        | Notes                                                                                                      |
|:------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------|:----------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------|
| Application data in PostgreSQL                                                                        | **Yes** (10.2)                                               | **Yes** (10.2)                                            |                                                                                                            |
| Project repository                                                                                    | **Yes** (10.2)                                               | **Yes** (10.7)                                            |                                                                                                            |
| Project wiki repository                                                                               | **Yes** (10.2)                                               | **Yes** (10.7)                                            |                                                                                                            |
| Project designs repository                                                                            | **Yes** (12.7)                                               | [No](https://gitlab.com/gitlab-org/gitlab/-/issues/32467) |                                                                                                            |
| Uploads                                                                                               | **Yes** (10.2)                                               | [No](https://gitlab.com/groups/gitlab-org/-/epics/1817)   | Verified only on transfer, or manually (*1*)                                                               |
| LFS objects                                                                                           | **Yes** (10.2)                                               | [No](https://gitlab.com/gitlab-org/gitlab/-/issues/8922)  | Verified only on transfer, or manually (*1*). Unavailable for new LFS objects in 11.11.x and 12.0.x (*2*). |
| CI job artifacts (other than traces)                                                                  | **Yes** (10.4)                                               | [No](https://gitlab.com/gitlab-org/gitlab/-/issues/8923)  | Verified only manually (*1*)                                                                               |
| Archived traces                                                                                       | **Yes** (10.4)                                               | [No](https://gitlab.com/gitlab-org/gitlab/-/issues/8923)  | Verified only on transfer, or manually (*1*)                                                               |
| Personal snippets                                                                                     | **Yes** (10.2)                                               | **Yes** (10.2)                                            |                                                                                                            |
| [Versioned snippets](../../../user/snippets.md#versioned-snippets)                                    | [No](https://gitlab.com/groups/gitlab-org/-/epics/2809)      | [No](https://gitlab.com/groups/gitlab-org/-/epics/2810)   |                                                                                                            |
| Project snippets                                                                                      | **Yes** (10.2)                                               | **Yes** (10.2)                                            |                                                                                                            |
| Object pools for forked project deduplication                                                         | **Yes**                                                      | No                                                        |                                                                                                            |
| [Server-side Git hooks](../../server_hooks.md)                                                        | No                                                           | No                                                        |                                                                                                            |
| [Elasticsearch integration](../../../integration/elasticsearch.md)                                    | [No](https://gitlab.com/gitlab-org/gitlab/-/issues/1186)     | No                                                        |                                                                                                            |
| [GitLab Pages](../../pages/index.md)                                                                  | [No](https://gitlab.com/groups/gitlab-org/-/epics/589)       | No                                                        |                                                                                                            |
| [Container Registry](../../packages/container_registry.md)                                            | **Yes** (12.3)                                               | No                                                        |                                                                                                            |
| [NPM Registry](../../../user/packages/npm_registry/index.md)                                          | **Yes** (13.2)                                               | No                                                        | Behind feature flag `geo_package_file_replication`, enabled by default                                     |
| [Maven Repository](../../../user/packages/maven_repository/index.md)                                  | **Yes** (13.2)                                               | No                                                        | Behind feature flag `geo_package_file_replication`, enabled by default                                     |
| [Conan Repository](../../../user/packages/conan_repository/index.md)                                  | **Yes** (13.2)                                               | No                                                        | Behind feature flag `geo_package_file_replication`, enabled by default                                     |
| [NuGet Repository](../../../user/packages/nuget_repository/index.md)                                  | **Yes** (13.2)                                               | No                                                        | Behind feature flag `geo_package_file_replication`, enabled by default                                     |
| [PyPi Repository](../../../user/packages/pypi_repository/index.md)                                    | **Yes** (13.2)                                               | No                                                        | Behind feature flag `geo_package_file_replication`, enabled by default                                     |
| [Composer Repository](../../../user/packages/composer_repository/index.md)                            | **Yes** (13.2)                                               | No                                                        | Behind feature flag `geo_package_file_replication`, enabled by default                                     |
| [External merge request diffs](../../merge_request_diffs.md)                                          | [No](https://gitlab.com/gitlab-org/gitlab/-/issues/33817)    | No                                                        |                                                                                                            |
| [Terraform State](../../terraform_state.md)                                                           | **Yes** (13.5)                                               | No                                                        |                                                                                                            |
| [Versioned Terraform State](../../terraform_state.md)                                                 | **Yes** (13.5)                                               | No                                                        |                                                                                                            |
| [Vulnerability Export](../../../user/application_security/security_dashboard/#export-vulnerabilities) | [No](https://gitlab.com/groups/gitlab-org/-/epics/3111)(*3*) | No                                                        |                                                                                                            |
| Content in object storage                                                                             | **Yes** (12.4)                                               | No                                                        |                                                                                                            |

- (*1*): The integrity can be verified manually using
  [Integrity Check Rake Task](../../raketasks/check.md) on both nodes and comparing
  the output between them.
- (*2*): GitLab versions 11.11.x and 12.0.x are affected by [a bug that prevents any new
  LFS objects from replicating](https://gitlab.com/gitlab-org/gitlab/-/issues/32696).
- (*3*): If you are using Object Storage, the replication can be performed by the
  Object Storage provider if supported. Please see [Geo with Object Storage](object_storage.md)
