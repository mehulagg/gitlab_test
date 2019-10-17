module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class Packages < Scenario::Template
            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = Release.new(release)
                gitlab.name = 'gitlab-packages'
                gitlab.network = 'test'
                gitlab.omnibus_config = <<~OMNIBUS
                  gitlab_rails['packages_enabled'] = true;
                OMNIBUS

                gitlab.instance do
                  puts "Running packages specs!"

                  rspec_args << "--" unless rspec_args.include?('--')
                  rspec_args << %w[--tag packages]

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
