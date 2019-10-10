module Gitlab
  module QA
    module Scenario
      module Test
        module Instance
          ##
          # Base class to be used to define deployment environment scenarios
          #
          class DeploymentBase < Scenario::Template
            def perform(release_name = nil, *args)
              Runtime::Env.require_no_license!

              release = if release_name.nil? || release_name.start_with?('--')
                          deployment_component.release
                        else
                          Release.new(release_name)
                        end

              args.unshift(release_name) if release_name&.start_with?('--')

              Component::Specs.perform do |specs|
                specs.suite = 'Test::Instance::All'
                specs.release = release
                specs.args = [deployment_component::ADDRESS, *args]
              end
            end

            def deployment_component
              raise NotImplementedError, 'Please define the Component for the deployment environment associated with this scenario.'
            end
          end
        end
      end
    end
  end
end
