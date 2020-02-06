require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class GroupSAML < SAML
            def initialize
              @gitlab_name = 'gitlab-group-saml'
              @spec_suite = 'QA::EE::Scenario::Test::Integration::GroupSAML'
              @saml_component = false
            end

            def before_perform(release)
              raise ArgumentError, 'Group SAML is EE only feature!' unless release.ee?
            end

            def configure(gitlab, saml)
              gitlab.omnibus_config = <<~OMNIBUS
                gitlab_rails['omniauth_enabled'] = true;
                gitlab_rails['omniauth_providers'] = [{ name: 'group_saml' }];
              OMNIBUS
            end
          end
        end
      end
    end
  end
end
