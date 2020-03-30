---
type: reference
---

# Database

GitLab supports only the use of PostgreSQL as its database.

NOTE: **Note:**
Prior to GitLab 12.1, MySQL was supported for Enterprise Edition licensed
instances. If you're using MySQL, you need to
[migrate to PostgreSQL](../../update/mysql_to_postgresql.html)
before upgrade to 12.1 and beyond.

## Requirements

Omnibus GitLab comes packaged with PostgreSQL configured with the appropriate
extensions and ready to go out of the box.

If you are [installing GitLab from source](https://docs.gitlab.com/ee/install/installation.html)
or choose to provide your own database, PostgreSQL requirements can be found in
GitLab [system requirements documentation](https://docs.gitlab.com/ee/install/requirements.html#postgresql-requirements).

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

## Standalone PostgreSQL server using Omnibus GitLab **(CORE ONLY)**

You can use the GitLab Omnibus package to easily
deploy the bundled PostgreSQL.

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

1. [Reconfigure GitLab] for the changes to take effect.
1. Note the PostgreSQL node's IP address or hostname, port, and
   plain text password. These will be necessary when configuring the GitLab
   application servers later.
1. [Enable monitoring](#enable-monitoring)

Advanced configuration options are supported and can be added if
needed.

