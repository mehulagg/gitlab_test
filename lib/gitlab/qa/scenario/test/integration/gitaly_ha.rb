module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class GitalyHA < Scenario::Template
            attr_reader :gitlab_name, :spec_suite

            def initialize
              @gitlab_name = 'gitlab-gitaly-ha'
              @primary_node = 'gitaly1'
              @secondary_node = 'gitaly2'
              @praefect_node = 'praefect'
              @database = 'postgres'
              @spec_suite = 'Test::Integration::GitalyHA'
              @network = 'test'
            end

            # rubocop:disable Metrics/AbcSize
            def perform(release, *rspec_args)
              gitaly(@primary_node, release) do
                gitaly(@secondary_node, release) do
                  Component::PostgreSQL.perform do |sql|
                    sql.name = @database
                    sql.network = @network

                    sql.instance do
                      sql.run_psql '-d template1 -c "CREATE DATABASE praefect_production OWNER postgres"'

                      Component::Gitlab.perform do |praefect|
                        praefect.release = Release.new(release)
                        praefect.name = @praefect_node
                        praefect.network = @network
                        praefect.skip_check = true

                        praefect.omnibus_config = praefect_omnibus_configuration

                        praefect.instance do
                          Component::Gitlab.perform do |gitlab|
                            gitlab.release = Release.new(release)
                            gitlab.name = gitlab_name
                            gitlab.network = @network

                            gitlab.omnibus_config = gitlab_omnibus_configuration
                            gitlab.instance do
                              puts "Running Gitaly HA specs!"

                              Component::Specs.perform do |specs|
                                specs.suite = spec_suite
                                specs.release = gitlab.release
                                specs.network = gitlab.network
                                specs.args = [gitlab.address, *rspec_args]
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            # rubocop:enable Metrics/AbcSize

            private

            def disable_other_services
              <<~OMNIBUS
                postgresql['enable'] = false;
                redis['enable'] = false;
                nginx['enable'] = false;
                prometheus['enable'] = false;
                grafana['enable'] = false;
                unicorn['enable'] = false;
                sidekiq['enable'] = false;
                gitlab_workhorse['enable'] = false;
                gitlab_rails['rake_cache_clear'] = false;
                gitlab_rails['auto_migrate'] = false;
              OMNIBUS
            end

            def praefect_omnibus_configuration
              <<~OMNIBUS
                #{disable_other_services}
                gitaly['enable'] = false;
                praefect['enable'] = true;
                praefect['listen_addr'] = '0.0.0.0:2305';
                praefect['prometheus_listen_addr'] = '0.0.0.0:9652';
                praefect['auth_token'] = 'PRAEFECT_EXTERNAL_TOKEN';
                praefect['database_host'] = '#{@database}.#{@network}';
                praefect['database_user'] = 'postgres';
                praefect['database_port'] = 5432;
                praefect['database_password'] = 'SQL_PASSWORD';
                praefect['database_dbname'] = 'praefect_production';
                praefect['database_sslmode'] = 'disable';
                praefect['postgres_queue_enabled'] = true;
                praefect['failover_enabled'] = true;
                praefect['virtual_storages'] = {
                  'default' => {
                    '#{@primary_node}' => {
                      'address' => 'tcp://#{@primary_node}.#{@network}:8075',
                      'token'   => 'PRAEFECT_INTERNAL_TOKEN',
                      'primary' => true
                    },
                    '#{@secondary_node}' => {
                      'address' => 'tcp://#{@secondary_node}.#{@network}:8075',
                      'token'   => 'PRAEFECT_INTERNAL_TOKEN'
                    }
                  }
                };
              OMNIBUS
            end

            def gitaly_omnibus_configuration
              <<~OMNIBUS
                #{disable_other_services}
                prometheus_monitoring['enable'] = false;
                gitaly['enable'] = true;
                gitaly['listen_addr'] = '0.0.0.0:8075';
                gitaly['prometheus_listen_addr'] = '0.0.0.0:9236';
                gitaly['auth_token'] = 'PRAEFECT_INTERNAL_TOKEN';
                gitlab_shell['secret_token'] = 'GITLAB_SHELL_SECRET_TOKEN';
                gitlab_rails['internal_api_url'] = 'http://#{@gitlab_name}.#{@network}';
                git_data_dirs({
                  '#{@primary_node}' => {
                    'path' => '/var/opt/gitlab/git-data'
                  },
                  '#{@secondary_node}' => {
                    'path' => '/var/opt/gitlab/git-data'
                  }
                });
              OMNIBUS
            end

            def gitlab_omnibus_configuration
              <<~OMNIBUS
                git_data_dirs({
                  'default' => {
                    'gitaly_address' => 'tcp://#{@praefect_node}.#{@network}:2305',
                    'gitaly_token' => 'PRAEFECT_EXTERNAL_TOKEN'
                  }
                });
                gitlab_shell['secret_token'] = 'GITLAB_SHELL_SECRET_TOKEN';
              OMNIBUS
            end

            def gitaly(name, release)
              Component::Gitlab.perform do |gitaly|
                gitaly.release = Release.new(release)
                gitaly.name = name
                gitaly.network = @network
                gitaly.skip_check = true

                gitaly.omnibus_config = gitaly_omnibus_configuration

                gitaly.instance do
                  yield self
                end
              end
            end
          end
        end
      end
    end
  end
end
