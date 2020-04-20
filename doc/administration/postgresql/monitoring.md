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
