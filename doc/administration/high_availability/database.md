---
type: reference
---

# Configuring PostgreSQL for Scaling and High Availability

In this section, you'll be guided through configuring a PostgreSQL database
to be used with GitLab in a highly available environment.

## Provide your own PostgreSQL instance **(CORE ONLY)**

If you're hosting GitLab on a cloud provider, you can optionally use a
managed service for PostgreSQL. For example, AWS offers a managed Relational
Database Service (RDS) that runs PostgreSQL.

If you use a cloud-managed service, or provide your own PostgreSQL:

1. Set up PostgreSQL according to the
   [database requirements document](../../install/requirements.md#database).
1. Set up a `gitlab` username with a password of your choice. The `gitlab` user
   needs privileges to create the `gitlabhq_production` database.
1. Configure the GitLab application servers with the appropriate details.
   This step is covered in [Configuring GitLab for HA](gitlab.md).

## PostgreSQL in a Scaled and Highly Available Environment

This section is relevant for [Scalable and Highly Available Setups](../scaling/index.md).

### Provide your own PostgreSQL instance **(CORE ONLY)**

If you want to use your own deployed PostgreSQL instance(s),
see [Provide your own PostgreSQL instance](#provide-your-own-postgresql-instance-core-only)
for more details. However, you can use the GitLab Omnibus package to easily
deploy the bundled PostgreSQL.

### Standalone PostgreSQL using GitLab Omnibus **(CORE ONLY)**


### High Availability with GitLab Omnibus **(PREMIUM ONLY)**


## Enable Monitoring


## Troubleshooting

### Consul and PostgreSQL changes not taking effect


### `gitlab-ctl repmgr-check-master` command produces errors


### PgBouncer error `ERROR: pgbouncer cannot connect to server`


### Issues with other components

## Configure using Omnibus

**Note**: We recommend that you follow the instructions here for a full [PostgreSQL cluster](#high-availability-with-gitlab-omnibus-premium-only).
If you are reading this section due to an old bookmark, you can find that old documentation [in the repository](https://gitlab.com/gitlab-org/gitlab/blob/v10.1.4/doc/administration/high_availability/database.md#configure-using-omnibus).

Read more on high-availability configuration:

1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the GitLab application servers](gitlab.md)
1. [Configure the load balancers](load_balancer.md)
1. [Manage the bundled Consul cluster](consul.md)
