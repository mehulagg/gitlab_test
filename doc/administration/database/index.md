---
type: reference
---

# Database

GitLab supports only the use of PostgreSQL as its database.

NOTE: **Note:**
Prior to GitLab 12.1, MySQL was supported for Enterprise Edition licensed
instances. If you're using MySQL, you need to [migrate to PostgreSQL](../../update/mysql_to_postgresql.md)
before upgrade to 12.1 and beyond.

This page documents administration tasks for the Omnibus-bundled PostgreSQL
service. For details on other aspects of GitLab database administration, please
read:

- [Configuring the GitLab application services' database client](app_configuration.md)
- [Using an external database with GitLab](external_database.md)
- [Standalone PostgreSQL server using Omnibus GitLab](standalone_database.md)

## Omnibus-bundled PostgreSQL

### Connecting to the bundled PostgreSQL database

If you need to connect to the bundled PostgreSQL database, you can
connect as the application user:

```shell
sudo gitlab-rails dbconsole
```

or as a PostgreSQL superuser:

```shell
sudo gitlab-psql -d gitlabhq_production
```

### Configuration

#### Storing PostgreSQL data in a different directory

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

#### Allowing PostgreSQL service to listen over TCP/IP

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

#### Configuring PostgreSQL SSL mode

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

#### Configuring PostgreSQL to use a custom SSL certificate

Omnibus GitLab automatically generates a self-signed certificate and private key
and stores them in the `/var/opt/gitlab/postgresql/data` directory by default.

If you'd prefer to use a CA-signed certificate, you'll need:

1. The public SSL certificate for the database (`server.crt`).
1. The corresponding private key for the SSL certificate (`server.key`).
1. A root certificate bundle that validates the server's certificate
   (`cacert.pem`). By default, Omnibus GitLab will use the embedded certificate
   bundle in `/opt/gitlab/embedded/ssl/certs/cacert.pem`.

For more details, see the [PostgreSQL documentation](https://www.postgresql.org/docs/9.6/ssl-tcp.html).

Note that `server.crt` and `server.key` may be different from the default SSL
certificates used to access GitLab. For example, suppose the external hostname
of your database is `database.example.com`, and your external GitLab hostname
is `gitlab.example.com`. You will either need a wildcard certificate for
`*.example.com` or two different SSL certificates.

With these files in hand, enable SSL:

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   postgresql['ssl_cert_file'] = '/custom/path/to/server.crt'
   postgresql['ssl_key_file'] = '/custom/path/to/server.key'
   postgresql['ssl_ca_file'] = '/custom/path/to/cacert.pem'
   postgresql['internal_certificate'] = "-----BEGIN CERTIFICATE-----
   ...base64-encoded certificate...
   -----END CERTIFICATE-----
   "
   postgresql['internal_key'] = "-----BEGIN RSA PRIVATE KEY-----
   ...base64-encoded private key...
   -----END RSA PRIVATE KEY-----
   "
   ```

   Relative paths will be rooted from the PostgreSQL data directory
   (`/var/opt/gitlab/postgresql/data` by default).

   NOTE: **Note:**
   You must ensure that the `gitlab-psql` user can access the directory the
   files are placed in and can read the private key. Omnibus will automatically
   manage the permissions of the files for you.

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab to apply the configuration changes.

1. Restart PostgreSQL for the changes to take effect:

   ```shell
   sudo gitlab-ctl restart postgresql
   ```

### Verifying that SSL is being used

To check whether SSL is being used by clients, you can run:

```shell
sudo gitlab-rails dbconsole
```

At startup, you should see a banner as the following:

```shell
psql (9.6.5)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: on)
Type "help" for help.
```

To check whether clients are using SSL, you can issue this SQL query:

```sql
SELECT * FROM pg_stat_ssl;
```

For example:

```sql
gitlabhq_production=> SELECT * FROM pg_stat_ssl;
  pid  | ssl | version |           cipher            | bits | compression | clientdn
-------+-----+---------+-----------------------------+------+-------------+----------
 47506 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47509 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47510 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47527 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47528 | f   |         |                             |      |             |
 47537 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47560 | f   |         |                             |      |             |
 47561 | f   |         |                             |      |             |
 47563 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47564 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47565 | f   |         |                             |      |             |
 47569 | f   |         |                             |      |             |
 47570 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47573 | f   |         |                             |      |             |
 47585 | f   |         |                             |      |             |
 47586 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47618 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 47628 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
 55812 | t   | TLSv1.2 | ECDHE-RSA-AES256-GCM-SHA384 |  256 | t           |
(19 rows)
```

Rows that have `t` listed under the `ssl` column are enabled.

### Upgrading

Omnibus GitLab will automatically update PostgreSQL to the
[default shipped version](https://docs.gitlab.com/omnibus/package-information/postgresql_versions.md)
during package upgrades unless specifically opted out.

To opt out of automatic PostgreSQL upgrade during GitLab package upgrades, run:

```shell
sudo touch /etc/gitlab/disable-postgresql-upgrade
```

If you want to manually upgrade the PostgreSQL service, you can follow these
instructions:

**Note:**

- Fully read this section before running any commands.
- Plan ahead as upgrade involves downtime.
- If you encounter any problems during upgrade, please raise an issue with a
  full description in the [Omnibus GitLab issue tracker](https://gitlab.com/gitlab-org/omnibus-gitlab).

Before upgrading, check the following:

- You're currently running the latest version of GitLab and it is working.
- If you recently upgraded, make sure that a [GitLab reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
  ran successfully before you proceed.
- You will need to have sufficiency disk space for two copies of your database.
  **Do not attempt to upgrade unless you have enough free space available.**
  Check your database size using `sudo su -sh /var/opt/gitlab/postgresql/data`
  (or your database path, if customized) and space available using `sudo df -h`.
  If the parition where the database resides does not have enough space, you can
  pass the argument `--tmp-dir $DIR` to the command.

NOTE: **Note:**
The upgrade requires downtime as the database must be down while the upgrade is
being performed. The length of downtime depends on the size of your database. If
you would rather avoid downtime, it is possible to upgrade to a new database
using [Slony](https://www.slony.info/). Please see our [guide](../../update/upgrading_postgresql_using_slony.md)
on how to perform the upgrade.

Once you have confirmed that the above checklist is satisfied, you can proceed.
To perform the upgrade, run the command:

```shell
sudo gitlab-ctl pg-upgrade
```

NOTE: **Note:**
In GitLab 12.8 or later, you can pass the `-V 11` flag to opt in to upgrading to PostgreSQL 11.

This command performs the following steps:

1. Checks to ensure the database is in a known good state
1. Shuts down the existing database, any unnecessary services, and enables the
   GitLab deploy page.
1. Changes the symlinks in `/opt/gitlab/embedded/bin/` for PostgreSQL to point
   to the newer version of the database
1. Creates a new directory containing a new, empty database with a locale
   matching the existing database
1. Uses the `pg_upgrade` tool to copy the data from the old database to the new
   database
1. Moves the old database out of the way
1. Moves the new database to the expected location
1. Calls `sudo gitlab-ctl reconfigure` to do the required configuration changes,
   and start the new database server.
1. Start the remaining services, and remove the deploy page.
1. If any errors are detected during this process, it should immediately revert
   to the old version of the database.

Once this step is complete, verify everything is working as expected.

Once this step is complete, verify everything is working as expected.

**Once you have verified that your GitLab instance is running correctly**,
you can clean up the old database files with:

```shell
sudo rm -rf /var/opt/gitlab/postgresql/data.<old_version>
sudo rm -f /var/opt/gitlab/postgresql-version.old
```

You can find details of PostgreSQL versions shipped with various GitLab versions
in [PostgreSQL versions shipped with Omnibus GitLab](https://docs.gitlab.com/omnibus/package-information/postgresql_versions.md).
The following section details their update policy.

#### GitLab 12.8 and later

**As of GitLab 12.8, PostgreSQL 9.6.17, 10.12, and 11.7 are shipped with
Omnibus GitLab.**

Automatically during package upgrades (unless opted out) and when user manually
runs `gitlab-ctl pg-upgrade`, `omnibus-gitlab` will still be attempting to
upgrade the database only to 10.x, while 11.x will be available for users to
manually upgrade to. To manually update PostgreSQL to version 11.x , the `pg-upgrade`
command has to be passed with a version argument (`-V` or `--target-version`)

```shell
sudo gitlab-ctl pg-upgrade -V 11
```

NOTE: **Note:**
We **DO NOT** recommend updating to PostgreSQL 11.x on GitLab instances making use of
GitLab Geo for replication, as we have not yet completed PostgreSQL 11 testing with GitLab
Geo. We will be [completing this work](https://gitlab.com/gitlab-org/omnibus-gitlab/issues/4975)
in a future release.

#### GitLab 12.0 and later

**As of GitLab 12.0, PostgreSQL 9.6.11 and 10.7 are shipped with Omnibus
GitLab.**

On upgrades, we will be automatically upgrading the database to 10.7 unless
specifically opted out as described above.

#### GitLab 11.11 and later

**As of GitLab 11.11, PostgreSQL 9.6.X and 10.7 are shipped with Omnibus
GitLab.**

Fresh installs will be getting PostgreSQL 10.7 while GitLab package upgrades
will retain the existing version of PostgreSQL. Users can manually upgrade to
the 10.7 using the `pg-upgrade` command as mentioned above.

### Downgrading

On GitLab versions which ship multiple PostgreSQL versions, users can downgrade
an already upgraded PostgreSQL version to the earlier version using:

```shell
sudo gitlab-ctl revert-pg-upgrade
```

This command also supports the `-V` flag to specify a target version for
scenarios where more than two PostgreSQL versions are shipped in the package.
For example, GitLab 12.8 ships with PostgreSQL 9.6.x, 10.x and 11.x.

If the target version is not specified, it will use the version in
`/var/opt/gitlab/postgresql-version.old` if available. Otherwise, it falls back
to the default version shipped with GitLab.

On other GitLab versions which ship only one PostgreSQL version, you can't
downgrade your PostgreSQL version. You must downgrade GitLab to an older version
to do this.
