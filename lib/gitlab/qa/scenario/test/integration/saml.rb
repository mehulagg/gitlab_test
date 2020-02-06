require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class SAML < Scenario::Template
            attr_reader :gitlab_name, :spec_suite, :saml_component

            def configure(gitlab, saml)
              raise NotImplementedError
            end

            def before_perform(release)
              # no-op
            end

            def perform(release, *rspec_args)
              release = Release.new(release)
              before_perform(release)

              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.network = 'test'
                gitlab.name = gitlab_name
                gitlab.set_accept_insecure_certs

                if saml_component
                  Component::SAML.perform do |saml|
                    saml.network = 'test'
                    configure(gitlab, saml)

                    saml.instance do
                      run_specs(gitlab, release, *rspec_args)
                    end
                  end
                else
                  configure(gitlab, nil)
                  run_specs(gitlab, release, *rspec_args)
                end
              end
            end

            def run_specs(gitlab, release, *rspec_args)
              gitlab.instance do
                puts "Running #{spec_suite} specs!"

                Component::Specs.perform do |specs|
                  specs.suite = spec_suite
                  specs.release = release
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
