module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class Mattermost < Scenario::Template
            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.network = 'test'

                mattermost_hostname = "mattermost.#{gitlab.network}"
                mattermost_external_url = "http://#{mattermost_hostname}"

                gitlab.add_network_alias(mattermost_hostname)
                gitlab.omnibus_config = <<~OMNIBUS
                  mattermost_external_url '#{mattermost_external_url}';
                OMNIBUS

                gitlab.instance do
                  Component::Specs.perform do |specs|
                    specs.suite = 'Test::Integration::Mattermost'
                    specs.release = gitlab.release
                    specs.network = gitlab.network
                    specs.args = [gitlab.address, mattermost_external_url, *rspec_args]
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
