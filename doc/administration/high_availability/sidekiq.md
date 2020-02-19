---
type: reference
---

# Configuring Sidekiq

## External Sidekiq

Sidekiq requires connection to Redis, PostgreSQL and Gitaly instance.
The following is an example of a working Sidekiq node.

1. Generate Sidekiq configuration. In your `gitlab.rb` file:

   ```ruby
   sidekiq['listen_address'] = "10.10.1.48"
   ```

1. Setup Sidekiq's connection to Redis. In your `gitlab.rb` file:

   ```ruby
   ## Must be the same in every sentinel node
   redis['master_name'] = 'gitlab-redis'

   ## The same password for Redis authentication you set up for the master node.
   redis['master_password'] = 'YOUR_PASSOWORD'

   ## A list of sentinels with `host` and `port`
   gitlab_rails['redis_sentinels'] = [
       {'host' => '10.10.1.34', 'port' => 26379},
       {'host' => '10.10.1.35', 'port' => 26379},
       {'host' => '10.10.1.36', 'port' => 26379},
     ]
   ```

1. Setup Sidekiq's connection to Gitlay. In your `gitlab.rb` file:

   ```ruby
   git_data_dirs({
     'default' => { 'gitaly_address' => 'tcp://gitaly:8075' },
   })
   gitlab_rails['gitaly_token'] = 'YOUR_TOKEN'
   ```

1. Setup Sidekiq's connection to Postgres. In your `gitlab.rb` file:

   ```ruby
   gitlab_rails['db_host'] = '10.10.1.30'
   gitlab_rails['db_password'] = 'YOUR_PASSOWORD'
   gitlab_rails['db_port'] = '5432'
   gitlab_rails['db_adapter'] = 'postgresql'
   gitlab_rails['db_encoding'] = 'unicode'
   gitlab_rails['auto_migrate'] = false
   ```

   Remember to add the Sidekiq nodes to the Postgres whitelist:

   ```ruby
   postgresql['trust_auth_cidr_addresses'] = %w(127.0.0.1/32 10.10.1.30/32 10.10.1.31/32 10.10.1.32/32 10.10.1.33/32 10.10.1.38/32)
   ```

1. Here is an example of a minimal `gitlab.rb` file for a Sidekiq node:

   ```ruby
   ########################################
   #####        Services Disabled       ###
   ########################################

   nginx['enable'] = false
   grafana['enable'] = false
   prometheus['enable'] = false
   gitlab_rails['auto_migrate'] = false
   alertmanager['enable'] = false
   gitaly['enable'] = false
   gitlab_monitor['enable'] = false
   gitlab_workhorse['enable'] = false
   nginx['enable'] = false
   postgres_exporter['enable'] = false
   postgresql['enable'] = false
   redis['enable'] = false
   redis_exporter['enable'] = false
   unicorn['enable'] = false
   gitlab_exporter['enable'] = false

   ########################################
   ####              Redis              ###
   ########################################

   ## Must be the same in every sentinel node
   redis['master_name'] = 'gitlab-redis'

   ## The same password for Redis authentication you set up for the master node.
   redis['master_password'] = 'YOUR_PASSOWORD'

   ## A list of sentinels with `host` and `port`
   gitlab_rails['redis_sentinels'] = [
       {'host' => '10.10.1.34', 'port' => 26379},
       {'host' => '10.10.1.35', 'port' => 26379},
       {'host' => '10.10.1.36', 'port' => 26379},
     ]

   #######################################
   ###              Gitaly             ###
   #######################################

   git_data_dirs({
     'default' => { 'gitaly_address' => 'tcp://gitaly:8075' },
   })
   gitlab_rails['gitaly_token'] = 'YOUR_TOKEN'

   #######################################
   ###            Postgres             ###
   #######################################
   gitlab_rails['db_host'] = '10.10.1.30'
   gitlab_rails['db_password'] = 'YOUR_PASSOWORD'
   gitlab_rails['db_port'] = '5432'
   gitlab_rails['db_adapter'] = 'postgresql'
   gitlab_rails['db_encoding'] = 'unicode'
   gitlab_rails['auto_migrate'] = false

   #######################################
   ###      Sidekiq configuration      ###
   #######################################
   sidekiq['listen_address'] = "10.10.1.48"

   #######################################
   ###     Monitoring configuration    ###
   #######################################
   consul['enable'] = true
   consul['monitoring_service_discovery'] =  true

   consul['configuration'] = {
     bind_addr: '10.10.1.48',
     retry_join: %w(10.10.1.34 10.10.1.35 10.10.1.36)
   }

   # Set the network addresses that the exporters will listen on
   node_exporter['listen_address'] = '10.10.1.48:9100'

   # Rails Status for prometheus
   gitlab_rails['monitoring_whitelist'] = ['10.10.1.42', '127.0.0.1']
   ```

1. Run `gitlab-ctl reconfigure`

Related Sidekiq configuration:

1. [Extra Sidekiq processes](../operations/extra_sidekiq_processes.md)
1. [Using the GitLab-Sidekiq chart](https://docs.gitlab.com/charts/charts/gitlab/sidekiq/)
