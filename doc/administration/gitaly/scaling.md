# Scaling Git storage

Scaling Git storage to match the needs of your organization is important for the
performance of your GitLab instance.

GitLab's Git storage can be scaled in multiple ways:

- [Hardware](#hardware): dedicated Gitaly nodes with sufficient CPU, memory, and IOPS
- [Clustering](#clustering): add Gitaly nodes to increase availability and resources
- [Sharding](#sharding): distribute repositories across multiple clusters

It is recommended start 

## Hardware

Out of the box, GitLab will run on a single machine, including Git storage.
Large installations
Most GitLab installations are best served by the

See [Scaling](../scaling/) documentation.

## Clustering

NOTE: **[Alpha](https://about.gitlab.com/handbook/product/#alpha-beta-ga):**
Support for [horizontally distributing
reads](https://gitlab.com/groups/gitlab-org/-/epics/2013) within a HA Gitaly
cluster is in development. Do not use in a production environment.

Increasing the availability and performance (coming soon) of Git storage is
possible by configuring a [high availability Gitaly cluster](./praefect.md).

Adding additional Gitaly nodes to the cluster should improve the performance of
Git read and write operations by increasing available:

- CPU
- memory
- IOPS


## Sharding

Sharding can be used to improve the performance of Git storage when storage
can't be increased, or it is impractical to increase the number of Gitaly nodes
in a cluster.

Sharding can also be used for providing isolating noisy 
