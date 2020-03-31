---
type: reference
---

# Using an external PostgreSQL service with GitLab

If you're hosting GitLab on a cloud provider, you can optionally use a
managed service for PostgreSQL. For example, AWS offers a managed Relational
Database Service (RDS) that runs PostgreSQL.

Alternatively, you may opt to manage your own PostgreSQL instance or cluster
separate from the GitLab Omnibus package.

## Setup

### Requirements

Your external PostgreSQL service needs to be set up according to the GitLab
[database requirements documentation](../../install/requirements.html#postgresql-requirements).

You will also need to set up a user (Omnibus GitLab uses `gitlab` by default)
with a password of your choice. This user needs privileges to create the
`gitlabhq_production` database.

### Configure application client services

**For Omnibus installations**

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['db_adapter'] = 'postgresql'
   gitlab_rails['db_encoding'] = 'utf8'
   gitlab_rails['db_host'] = '10.1.0.5' # IP/hostname of database server
   gitlab_rails['db_port'] = 5432
   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_password'] = 'database_password'
   ```

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab for the changes to take effect.

**For installations from source**

Follow the [Configure GitLab DB Settings](../install/installation.html#configure-gitlab-db-settings) section in the
installation from source documentation.

NOTE: **Note:**
Additional application client service database connection options can be found
in the [application services database client configuration](app_configuration.md)
documentation.

### Initialize the database (for fresh installs only)

CAUTION: **Caution:**
This will drop your existing database and recreate it as though a fresh GitLab
install. Do not run it on a database with existing production data!

**For Omnibus installations**

Omnibus GitLab will not automatically seed your external database. Run the
following command to import the database schema and create the first admin user:

```shell
sudo gitlab-rake gitlab:setup
```

**For installations from source**

Follow the [Initialize Database](../install/installation.html#initialize-database-and-activate-advanced-features) section in the
installation from source documentation.

## Backup and restore using rake task

When using the [rake backup create and restore task](../../raketasks/backup_restore.md#create-a-backup-of-the-gitlab-system),
GitLab will attempt to use the packaged `pg_dump` command to craete a database
backup file and the packaged `psql` command to restore a backup. This will only
work if they are the correct versions. To check the versions of the packaged
`pg_dump` and `psql`:

```shell
/opt/gitlab/embedded/bin/pg_dump --version
/opt/gitlab/embedded/bin/psql --version
```

If these versions are different from your external PostgreSQL service, you will
need to install tools that match your database version and then follow the
steps below. There are multiple ways to install PostgreSQL client tools. See
https://www.postgresql.org/download/ for options.

Once the correct `psql` and `pg_dump` tools are available on your system,
follow these steps, using the correct path to the location you installed the
new tools:

1. Add symbolic links to the non-packaged versions:

   ```shell
   ln -s /path/to/new/pg_dump /path/to/new/psql /opt/gitlab/bin/
   ```

1. Check the versions:

   ```shell
   /opt/gitlab/bin/pg_dump --version
   /opt/gitlab/bin/psql --version
   ```

   They should now be the same as your external PostgreSQL service.

After this is done, ensure that the backup and restore tasks are using the
correct executables by running both the [backup](../../raketasks/backup_restore.md#create-a-backup-of-the-gitlab-system)
and [restore](../../raketasks/backup_restore.html#restore-a-previously-created-backup)
tasks.

## Upgrading the external PostgreSQL service

From time to time, GitLab will require the use of a more recent major version
of PostgreSQL. When upgrading your external PostgreSQL service, you will also
need to run the `ANALYZE VERBOSE;` query against your database to recreate
query plans.

CAUTION: **Caution:**
If you neglect to do so, you may see extremely high (near 100%) CPU utilization
following a major PostgreSQL version upgrade.
