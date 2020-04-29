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

1. SSH into the PostgreSQL server.
1. [Download/install](https://about.gitlab.com/install/) the Omnibus GitLab
   package you want using **steps 1 and 2** from the GitLab downloads page.
   - Do not complete any other steps on the download page.
1. Generate a password hash for PostgreSQL. This assumes you will use the default
   username of `gitlab` (recommended). The command will request a password
   and confirmation. Use the value that is output by this command in the next
   step as the value of `POSTGRESQL_PASSWORD_HASH`.

   ```shell
   sudo gitlab-ctl pg-password-md5 gitlab
   ```

1. Edit `/etc/gitlab/gitlab.rb` and add the contents below, updating placeholder
   values appropriately.

   - `POSTGRESQL_PASSWORD_HASH` - The value output from the previous step
   - `APPLICATION_SERVER_IP_BLOCKS` - A space delimited list of IP subnets or IP
     addresses of the GitLab application servers that will connect to the
     database. Example: `%w(123.123.123.123/32 123.123.123.234/32)`

   ```ruby
   # Disable all components except PostgreSQL
   roles ['postgres_role']
   repmgr['enable'] = false
   consul['enable'] = false
   prometheus['enable'] = false
   alertmanager['enable'] = false
   pgbouncer_exporter['enable'] = false
   redis_exporter['enable'] = false
   gitlab_exporter['enable'] = false

   postgresql['listen_address'] = '0.0.0.0'
   postgresql['port'] = 5432

   # Replace POSTGRESQL_PASSWORD_HASH with a generated md5 value
   postgresql['sql_user_password'] = 'POSTGRESQL_PASSWORD_HASH'

   # Replace XXX.XXX.XXX.XXX/YY with Network Address
   # ????
   postgresql['trust_auth_cidr_addresses'] = %w(APPLICATION_SERVER_IP_BLOCKS)

   # Disable automatic database migrations
   gitlab_rails['auto_migrate'] = false
   ```

   NOTE: **Note:** The role `postgres_role` was introduced with GitLab 10.3

1. [Reconfigure GitLab](../restart_gitlab.md#omnibus-gitlab-reconfigure) for the changes to take effect.
1. Note the PostgreSQL node's IP address or hostname, port, and
   plain text password. These will be necessary when configuring the GitLab
   application servers later.
1. [Enable monitoring](#enable-monitoring)

Advanced configuration options are supported and can be added if
needed.

### High Availability with GitLab Omnibus **(PREMIUM ONLY)**

This content was moved to [another location](../postgresql/high_availability.md).

## Enable Monitoring

> [Introduced](https://gitlab.com/gitlab-org/omnibus-gitlab/issues/3786) in GitLab 12.0.

If you enable Monitoring, it must be enabled on **all** database servers.

1. Create/edit `/etc/gitlab/gitlab.rb` and add the following configuration:

   ```ruby
   # Enable service discovery for Prometheus
   consul['monitoring_service_discovery'] = true

   # Set the network addresses that the exporters will listen on
   node_exporter['listen_address'] = '0.0.0.0:9100'
   postgres_exporter['listen_address'] = '0.0.0.0:9187'
   ```

1. Run `sudo gitlab-ctl reconfigure` to compile the configuration.

## Troubleshooting

### Consul and PostgreSQL changes not taking effect

Due to the potential impacts, `gitlab-ctl reconfigure` only reloads Consul and PostgreSQL, it will not restart the services. However, not all changes can be activated by reloading.

To restart either service, run `gitlab-ctl restart SERVICE`

For PostgreSQL, it is usually safe to restart the master node by default. Automatic failover defaults to a 1 minute timeout. Provided the database returns before then, nothing else needs to be done. To be safe, you can stop `repmgrd` on the standby nodes first with `gitlab-ctl stop repmgrd`, then start afterwards with `gitlab-ctl start repmgrd`.

On the Consul server nodes, it is important to restart the Consul service in a controlled fashion. Read our [Consul documentation](consul.md#restarting-the-server-cluster) for instructions on how to restart the service.

### `gitlab-ctl repmgr-check-master` command produces errors

If this command displays errors about database permissions it is likely that something failed during
install, resulting in the `gitlab-consul` database user getting incorrect permissions. Follow these
steps to fix the problem:

1. On the master database node, connect to the database prompt - `gitlab-psql -d template1`
1. Delete the `gitlab-consul` user - `DROP USER "gitlab-consul";`
1. Exit the database prompt - `\q`
1. [Reconfigure GitLab](../restart_gitlab.md#omnibus-gitlab-reconfigure) and the user will be re-added with the proper permissions.
1. Change to the `gitlab-consul` user - `su - gitlab-consul`
1. Try the check command again - `gitlab-ctl repmgr-check-master`.

Now there should not be errors. If errors still occur then there is another problem.

### PgBouncer error `ERROR: pgbouncer cannot connect to server`

You may get this error when running `gitlab-rake gitlab:db:configure` or you
may see the error in the PgBouncer log file.

```plaintext
PG::ConnectionBad: ERROR:  pgbouncer cannot connect to server
```

The problem may be that your PgBouncer node's IP address is not included in the
`trust_auth_cidr_addresses` setting in `/etc/gitlab/gitlab.rb` on the database nodes.

You can confirm that this is the issue by checking the PostgreSQL log on the master
database node. If you see the following error then `trust_auth_cidr_addresses`
is the problem.

```plaintext
2018-03-29_13:59:12.11776 FATAL:  no pg_hba.conf entry for host "123.123.123.123", user "pgbouncer", database "gitlabhq_production", SSL off
```

To fix the problem, add the IP address to `/etc/gitlab/gitlab.rb`.

```ruby
postgresql['trust_auth_cidr_addresses'] = %w(123.123.123.123/32 <other_cidrs>)
```

[Reconfigure GitLab](../restart_gitlab.md#omnibus-gitlab-reconfigure) for the changes to take effect.

### Issues with other components

If you're running into an issue with a component not outlined here, be sure to check the troubleshooting section of their specific documentation page.

- [Consul](consul.md#troubleshooting)
- [PostgreSQL](https://docs.gitlab.com/omnibus/settings/database.html#troubleshooting)
- [GitLab application](gitlab.md#troubleshooting)

## Configure using Omnibus

**Note**: We recommend that you follow the instructions here for a full [PostgreSQL cluster](#high-availability-with-gitlab-omnibus-premium-only).
If you are reading this section due to an old bookmark, you can find that old documentation [in the repository](https://gitlab.com/gitlab-org/gitlab/blob/v10.1.4/doc/administration/high_availability/database.md#configure-using-omnibus).

Read more on high-availability configuration:

1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the GitLab application servers](gitlab.md)
1. [Configure the load balancers](load_balancer.md)
1. [Manage the bundled Consul cluster](consul.md)
