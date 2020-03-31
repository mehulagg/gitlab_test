---
type: reference
---

# Using an external PostgreSQL service with GitLab

If you're hosting GitLab on a cloud provider, you can optionally use a
managed service for PostgreSQL. For example, AWS offers a managed Relational
Database Service (RDS) that runs PostgreSQL.

Alternatively, you may opt to manage your own PostgreSQL instance or cluster
separate from the GitLab Omnibus package.

## Requirements

Your external PostgreSQL service needs to be set up according to the GitLab
[database requirements documentation](../../install/requirements.html#postgresql-requirements).

You will also need to set up a user (Omnibus GitLab uses `gitlab` by default)
with a password of your choice. This user needs privileges to create the
`gitlabhq_production` database.

## Configure application services

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

## Initialize the database (for fresh installs only)

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

## Upgrading the external PostgreSQL service

From time to time, GitLab will require the use of a more recent major version
of PostgreSQL. When upgrading your external PostgreSQL service, you will also
need to run the `ANALYZE VERBOSE;` query against your database to recreate
query plans.

CAUTION: **Caution:**
If you neglect to do so, you may see extremely high (near 100%) CPU utilization
following a major PostgreSQL version upgrade.
