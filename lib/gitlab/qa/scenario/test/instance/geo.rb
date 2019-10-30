module Gitlab
  module QA
    module Scenario
      module Test
        module Instance
          # Run Geo test suite against any GitLab Geo (two-node) instance,
          # including staging and on-premises installation.

          class Geo < Scenario::Template
            def perform(release, primary_address, secondary_address, *rspec_args)
              # Geo requires an EE license
              Runtime::Env.require_license!

              Component::Specs.perform do |specs|
                specs.suite = 'QA::EE::Scenario::Test::Geo'
                specs.release = Release.new(release)
                specs.network = 'geo'
                specs.args = [
                  '--primary-address', primary_address,
                  '--secondary-address', secondary_address,
                  '--without-setup',
                  *rspec_args
                ]
              end
            end
          end
        end
      end
    end
  end
end
