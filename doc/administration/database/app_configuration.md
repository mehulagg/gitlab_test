---
type: reference
---

# Application services client database connection settings

The Unicorn and Sidekiq application services are the primary database clients
in a GitLab instance.

## Configuring statement timeout

The amount of time that Unicorn or Sidekiq will wait for a database transaction
to complete before timing out can now be adjusted:

**For Omnibus installations**

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['db_statement_timeout'] = 45000 # Specified in milliseconds
   ```

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab for the changes to take effect.

If `gitlab_rails['db_statement_timeout']` is not specified, Omnibus GitLab
uses the value of `postgresql['statement_timeout']` if present. Otherwise, a
default value of `60000` (60 seconds) is used.

## Connecting to a PostgreSQL service over TCP/IP

**For Omnibus installations**

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['db_adapter'] = 'postgresql'
   gitlab_rails['db_encoding'] = 'utf8'
   gitlab_rails['db_host'] = '10.1.0.5' # IP or hostname of PostgreSQL server
   gitlab_rails['db_port'] = 5432
   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_password'] = 'database_password'
   ```

   NOTE: **Note:**
   `/etc/gitlab/gitlab.rb` should have file permissions `0600` because it contains
   plain-text passwords.

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab for the changes to take effect.

**For installations from source**

Follow the [Configure GitLab DB Settings](../install/installation.html#configure-gitlab-db-settings) section in the
installation from source documentation.

### Verify server SSL certificate against CA bundle

The application services can be configured to verify the PostgreSQL server
certificate against a CA bundle to prevent spoofing.

**For Omnibus installations**

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['db_sslmode'] = 'verify-full'
   gitlab_rails['db_sslrootcert'] = 'your-full-ca-bundle.pem'
   ```

   NOTE: **Note:**
   The CA bundle that is specified in `gitlab_rails['db_sslrootcert']` must
   contain both the root and intermediate certificates.

   NOTE: **Note:**
   If you are using Amazon RDS for your PostgreSQL server, ensure you download
   and use the [combined CA bundle](https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem)
   for `gitlab_rails['db_sslrootcert']`. More information on this can be found
   in the [Using SSL to Encrypt a Connection to a DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)
   article on AWS.

1. Save the file and [reconfigure](../restart_gitlab.md#omnibus-gitlab-reconfigure)
   GitLab to apply the configuration changes.   

1. Restart PostgreSQL for the changes to take effect:

   ```shell
   sudo gitlab-ctl restart postgresql
   ```

## Disable automatic database migration

If you have multiple GitLab servers sharing a database, you will want to limit
the number of nodes that are performing the migration steps during
reconfiguration. To do this:

**For Omnibus installations**

1. Edit `/etc/gitlab/gitlab.rb`:

   ```ruby
   gitlab_rails['auto_migrate'] = false
   ```

The next time a reconfigure is triggered, the migration steps will not be
performed.
