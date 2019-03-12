# Geo with external PostgreSQL instances

This document is relevant if you are using a PostgreSQL instance that is *not
managed by Omnibus*. This includes cloud-managed instances like AWS RDS, or
manually installed and configured PostgreSQL instances.

NOTE: **Note**:
We strongly recommend running Omnibus-managed instances as they are actively
developed and tested. We aim to be compatible with most external
(not managed by Omnibus) databases but we do not guarantee compatibility.

## **Primary** node

1. SSH into your GitLab **primary** server and login as root:

    ```sh
    sudo -i
    ```

1. Execute the command below to define the node as **primary** node:

    ```sh
    gitlab-ctl set-geo-primary-node
    ```

    This command will use your defined `external_url` in `/etc/gitlab/gitlab.rb`.


### Configure the external database to be replicated

To set up an external database, you can either:

- Set up streaming replication yourself (for example, in AWS RDS).
- Perform the Omnibus configuration manually as follows.

#### AWS RDS (as an example)

Given you have primary node set up on AWS EC2 that uses RDS.
You can now just create a read-only replica in a different region and the
replication process will be managed by AWS. Make sure you've set Network ACL, Subnet, and
Security Group according to your needs, so the secondary node instance can access the database.

#### Any other external database with access to `postgresql.conf`

The [geo_primary_role](https://docs.gitlab.com/omnibus/roles/#gitlab-geo-roles)
configures the **primary** node's database to be replicated by making changes to
`pg_hba.conf` and `postgresql.conf`. Make the following configuration changes
manually to your external database configuration:

```
##
## Geo Primary Role
## - pg_hba.conf
##
host    replication gitlab_replicator <trusted secondary IP>/32     md5
```

```
##
## Geo Primary Role
## - postgresql.conf
##
sql_replication_user = gitlab_replicator
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 50
max_replication_slots = 1 # number of secondary instances
hot_standby = on
```

## **Secondary** nodes

With Omnibus, the
[geo_secondary_role](https://docs.gitlab.com/omnibus/roles/#gitlab-geo-roles)
has three main functions:

1. Configure the replica database.
1. Configure the tracking database.
1. Enable the Geo Log Cursor (`geo_logcursor`) (irrelevant to this doc).

The first two steps we will set up manually as described bellow but the Log Cursor have to
be enabled anyway:

1. SSH into a GitLab **secondary** server and login as root:

    ```bash
    sudo -i
    ```

1. Edit `/etc/gitlab/gitlab.rb` and add the following

    ```ruby
    ##
    ## Geo Secondary role
    ## - configure dependent flags automatically to enable Geo
    ##
    roles ['geo_secondary_role']
    ```
1. Reconfigure GitLab for the changes to take effect:

    ```sh
    gitlab-ctl reconfigure
    ```



### Configure the external replica database

To set up an external replica database, you can either:

- Set up streaming replication yourself (for example, in AWS RDS).
- Perform the Omnibus configuration manually as follows.

Make the following configuration changes manually to your `postgresql.conf`
of external replica database:

```
##
## Geo Secondary Role
## - postgresql.conf
##
wal_level = hot_standby
max_wal_senders = 10
wal_keep_segments = 10
hot_standby = on
```

### Configure an access to the external replica database

1. SSH into a GitLab **secondary** server and login as root:

    ```bash
    sudo -i
    ```

1. Edit `/etc/gitlab/gitlab.rb` with the connection params and credentials for
    the machine with the PostgreSQL replica instance:

    ```ruby
    # note this is shared between both databases,
    # make sure you define the same password in both
    gitlab_rails['db_password'] = 'mypassword'

    gitlab_rails['db_username'] = 'gitlab'
    gitlab_rails['db_host'] = 'my-database-read-replica.dbs.com'
    ```

1. Reconfigure GitLab for the changes to take effect:

    ```bash
    gitlab-ctl reconfigure
    ```


### Configure the tracking database

**Secondary** nodes use a separate PostgreSQL installation as a tracking
database to keep track of replication status and automatically recover from
potential replication issues.

It requires an [FDW](https://www.postgresql.org/docs/9.6/static/postgres-fdw.html)
connection with the **secondary** replica database for improved performance.

If you have an external database ready to be used as the tracking database,
follow the instructions below to use it:

NOTE: **Note:**
If you use AWS RDS for tracking database, make sure your tracking database has access to
secondary database. Unfortunatelly, just assigning the same security group is not enough as
outbound rules do not apply to RDS PostgreSQL database. So you need to explicitly add inbound
rule for security group to allow any TCP traffic from tracking database to 5432 port.


1. SSH into a GitLab **secondary** server and login as root:

    ```bash
    sudo -i
    ```

1. Edit `/etc/gitlab/gitlab.rb` with the connection params and credentials for
    the machine with the PostgreSQL instance:

    ```ruby
    geo_secondary['db_username'] = 'gitlab_geo'
    geo_secondary['db_password'] = 'my password'

    geo_secondary['db_host'] = '<change to the tracking DB host>'
    geo_secondary['db_port'] = 5432      # change to the correct port
    geo_secondary['db_fdw'] = true       # enable FDW
    geo_postgresql['enable'] = false     # don't use internal managed instance
    ```

1. Reconfigure GitLab for the changes to take effect:

    ```bash
    gitlab-ctl reconfigure
    ```

1. Run the tracking database migrations:

    ```bash
    gitlab-rake geo:db:create
    gitlab-rake geo:db:migrate
    ```

1. Configure the
    [PostgreSQL FDW](https://www.postgresql.org/docs/9.6/static/postgres-fdw.html)
    connection and credentials:

    Save the script below in a file, ex. `/tmp/geo_fdw.sh` and modify the connection
    params to match your environment. Execute it to set up the FDW connection.

    ```bash
    #!/bin/bash

    # Secondary Database connection params:
    DB_HOST="<change to the public IP or VPC private IP>"
    DB_NAME="gitlabhq_production"
    DB_USER="gitlab"
    DB_PASS="my password"
    DB_PORT="5432"

    # Tracking Database connection params:
    GEO_DB_HOST="<change to the public IP or VPC private IP>"
    GEO_DB_NAME="gitlabhq_geo_production"
    GEO_DB_USER="gitlab_geo"
    GEO_DB_PORT="5432"

    query_exec () {
      gitlab-psql -h $GEO_DB_HOST -d $GEO_DB_NAME -p $GEO_DB_PORT -c "${1}"
    }

    query_exec "CREATE EXTENSION postgres_fdw;"
    query_exec "CREATE SERVER gitlab_secondary FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${DB_HOST}', dbname '${DB_NAME}', port '${DB_PORT}');"
    query_exec "CREATE USER MAPPING FOR ${GEO_DB_USER} SERVER gitlab_secondary OPTIONS (user '${DB_USER}', password '${DB_PASS}');"
    query_exec "CREATE SCHEMA gitlab_secondary;"
    query_exec "GRANT USAGE ON FOREIGN SERVER gitlab_secondary TO ${GEO_DB_USER};"
    ```

    NOTE: **Note:** The script template above uses `gitlab-psql` as it's intended to be executed from the Geo machine,
    but you can change it to `psql` and run it from any machine that has access to the database.

1. Restart GitLab:

    ```bash
    gitlab-ctl restart
    ```
1. Populate the FDW tables:

    ```bash
    gitlab-rake geo:db:refresh_foreign_tables
    ```
