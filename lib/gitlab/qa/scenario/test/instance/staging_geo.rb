module Gitlab
  module QA
    module Scenario
      module Test
        module Instance
          ##
          # Run test suite against staging.gitlab.com
          #
          class StagingGeo < DeploymentBase
            def initialize
              @suite = 'QA::EE::Scenario::Test::Geo'
            end

            def deployment_component
              Component::Staging
            end

            def non_rspec_args
              [
                '--primary-address', deployment_component::ADDRESS,
                '--secondary-address', deployment_component::GEO_SECONDARY_ADDRESS,
                '--without-setup'
              ]
            end
          end
        end
      end
    end
  end
end
