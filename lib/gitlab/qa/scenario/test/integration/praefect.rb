module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class Praefect < Scenario::Template
            # rubocop:disable Metrics/AbcSize
            def perform(release, *rspec_args)
              Docker::Volumes.new.with_temporary_volumes do |volumes|
                # Create the Praefect database before enabling Praefect
                Component::Gitlab.perform do |gitlab|
                  gitlab.release = Release.new(release)
                  gitlab.name = 'gitlab'
                  gitlab.network = 'test'
                  gitlab.volumes = volumes
                  gitlab.exec_commands = ['gitlab-psql -d template1 -c "CREATE DATABASE praefect_production OWNER gitlab"']

                  gitlab.act(omnibus_config_with_praefect) do |new_config|
                    prepare
                    start
                    reconfigure
                    process_exec_commands
                    wait
                    teardown
                  end
                end

                # Restart GitLab with Praefect enabled and then run the tests
                Component::Gitlab.perform do |gitlab|
                  gitlab.release = Release.new(release)
                  gitlab.name = 'gitlab'
                  gitlab.network = 'test'
                  gitlab.volumes = volumes
                  gitlab.omnibus_config = omnibus_config_with_praefect

                  gitlab.act do
                    start
                    reconfigure
                    wait

                    puts "Running Praefect specs!"

                    Component::Specs.perform do |specs|
                      specs.suite = 'Test::Instance::All'
                      specs.release = gitlab.release
                      specs.network = gitlab.network
                      specs.args = [gitlab.address, *rspec_args]
                      specs.env = { QA_PRAEFECT_REPOSITORY_STORAGE: 'default' }
                    end

                    teardown
                  end
                end
              end
            end
            # rubocop:enable Metrics/AbcSize

            private

            def omnibus_config_with_praefect
              <<~OMNIBUS
                gitaly['enable'] = true;
                gitaly['auth_token'] = 'praefect-gitaly-token';
                gitaly['storage'] = [
                  {
                    'name' => 'praefect-gitaly-0',
                    'path' => '/var/opt/gitlab/git-data/repositories'
                  }
                ];
                praefect['enable'] = true;
                praefect['listen_addr'] = '0.0.0.0:2305';
                praefect['auth_token'] = 'praefect-token';
                praefect['virtual_storages'] = {
                  'default' => {
                    'praefect-gitaly-0' => {
                      'address' => 'unix:/var/opt/gitlab/gitaly/gitaly.socket',
                      'token'   => 'praefect-gitaly-token',
                      'primary' => true
                    }
                  }
                };
                praefect['database_host'] = '/var/opt/gitlab/postgresql';
                praefect['database_user'] = 'gitlab';
                praefect['database_dbname'] = 'praefect_production';
                praefect['postgres_queue_enabled'] = true;
                gitlab_rails['gitaly_token'] = 'praefect-token';
                git_data_dirs({
                  'default' => {
                    'gitaly_address' => 'tcp://localhost:2305'
                  }
                });
              OMNIBUS
            end
          end
        end
      end
    end
  end
end
