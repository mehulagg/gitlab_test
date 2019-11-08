module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class Praefect < Scenario::Template
            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = Release.new(release)
                gitlab.name = 'gitlab'
                gitlab.network = 'test'
                gitlab.omnibus_config = <<~OMNIBUS
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
                  praefect['virtual_storage_name'] = 'default';
                  praefect['storage_nodes'] = {
                    'praefect-gitaly-0' => {
                      'address' => 'unix:/var/opt/gitlab/gitaly/gitaly.socket',
                      'token'   => 'praefect-gitaly-token',
                      'primary' => true
                    }
                  };
                  gitlab_rails['gitaly_token'] = 'praefect-token';
                  git_data_dirs({
                    'default' => {
                      'gitaly_address' => 'tcp://localhost:2305'
                    }
                  });
                OMNIBUS

                gitlab.instance do
                  puts "Running Praefect specs!"

                  Component::Specs.perform do |specs|
                    specs.suite = 'Test::Instance::All'
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
