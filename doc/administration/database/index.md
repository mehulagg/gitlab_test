---
type: reference
---

# Database

GitLab supports only the use of PostgreSQL as its database.

NOTE: **Note:**
Prior to GitLab 12.1, MySQL was supported for Enterprise Edition licensed
instances. If you're using MySQL, you need to [migrate to PostgreSQL](../../update/mysql_to_postgresql.md)
before upgrade to 12.1 and beyond.

## Application services client configuration

Application services client database connection options can be found
in the [application services database client configuration](app_configuration.md)
documentation.

## Omnibus-bundled PostgreSQL configuration

### Store PostgreSQL data in a different directory

CAUTION: **Caution:**
This is an intrusive operation. It cannot be done without downtime on an
existing installation.

By default, Omnibus GitLab stores PostgreSQL-related data in the
`/var/opt/gitlab/postgresql` directory. To change it:

1. Stop GitLab:

   ```shell
   sudo gitlab-ctl stop
   ```

1. If you have existing PostgreSQL data, copy them from the old location to the
   new location.

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   postgresql['dir'] = '/path/to/postgresql'
   ```

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab for the changes to take effect.

1. Start GitLab:

   ```shell
   sudo gitlab-ctl start
   ```

Note that changing the setting affects the following items:

- The actual PostgreSQL data, by default stored in `/var/opt/gitlab/postgresql/data`,
  will now be stored in this directory in a `data` sub-directory.
- The Unix socket used to connect to PostgreSQL, by default located at
  `/var/opt/gitlab/postgresql/.s.PGSQL.5432`, will be located in this directory.
  This can be configured separately with the `postgresql['unix_socket_directory']`
  configuration directive.
- The `HOME` directory of the `gitlab-psql` system will be set to this
  directory. This can be configured separately with the `postgresql['home']`
  configuration directive.

### Allow PostgreSQL service to listen over TCP/IP

The packaged PostgreSQL server can be configured to listen for TCP/IP
connections, with the caveat that some non-critical scripts expect UNIX sockets
and may misbehave. To enable it:

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   postgresql['listen_address'] = '0.0.0.0'
   postgresql['port'] = 5432

   # Configure the username and MD5 username-password hash used to access the
   # GitLab database
   postgresql['sql_user'] = 'gitlab'
   postgresql['sql_user_password'] = 'database_password'

   # Configure the list of CIDR address blocks allowed to connect after password
   # authentication
   postgresql['md5_auth_cidr_addresses'] = %w(10.200.0.1/24 10.300.0.1/24)

   # Configure the list of CIDR address blocks allowed to connect without
   # authentication of any kind. Be very careful with this with. It is suggested
   # to limit this to the loopback address of 17.0.0.1/24 or even 127.0.0.1/32.
   postgresql['trust_auth_cidr_addresses'] = %w(127.0.0.1/24)
   ```

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab for the changes to take effect.

### Configure PostgreSQL SSL mode

Omnibus GitLab automatically enables SSL on the PostgreSQL service, but will
accept both encrypted and unencrypted connections by default. This behavior can
be adjusted by changing the [SSL mode](https://www.postgresql.org/docs/9.6/libpq-ssl.html#LIBPQ-SSL-PROTECTION)
that the PostgreSQL service runs in. To set this:

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   postgresql['db_sslmode'] = 'require'
   ```

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab to apply the configuration changes.

1. Restart PostgreSQL for the changes to take effect:

   ```shell
   sudo gitlab-ctl restart postgresql
   ```

If PostgreSQL fails to start, check the logs at `/var/log/gitlab/postgresql/current`
for more details.

## Provide your own PostgreSQL instance **(CORE ONLY)**

It is possible to use GitLab with an [external PostgreSQL service](external_database.md).

## Standalone PostgreSQL server using Omnibus GitLab **(CORE ONLY)**

You can use the GitLab Omnibus package to easily deploy the bundled PostgreSQL.

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
1. [Enable monitoring]

Advanced configuration options are supported and can be added if
needed.
