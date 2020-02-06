require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class InstanceSAML < SAML
            def initialize
              @gitlab_name = 'gitlab-instance-saml'
              @spec_suite = 'Test::Integration::InstanceSAML'
              @saml_component = true
            end

            def configure(gitlab, saml)
              saml.set_entity_id(gitlab.address)
              saml.set_assertion_consumer_service("#{gitlab.address}/users/auth/saml/callback")
              saml.set_simple_saml_hostname

              gitlab.omnibus_config = <<~OMNIBUS
                gitlab_rails['omniauth_enabled'] = true;
                gitlab_rails['omniauth_allow_single_sign_on'] = ['saml'];
                gitlab_rails['omniauth_block_auto_created_users'] = false;
                gitlab_rails['omniauth_auto_link_saml_user'] = true;
                gitlab_rails['omniauth_providers'] = [
                  {
                    name: 'saml',
                    args: {
                             assertion_consumer_service_url: '#{gitlab.address}/users/auth/saml/callback',
                             idp_cert_fingerprint: '11:9b:9e:02:79:59:cd:b7:c6:62:cf:d0:75:d9:e2:ef:38:4e:44:5f',
                             idp_sso_target_url: 'https://#{saml.hostname}:8443/simplesaml/saml2/idp/SSOService.php',
                             issuer: '#{gitlab.address}',
                             name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
                           }
                  }
                ];
              OMNIBUS
            end
          end
        end
      end
    end
  end
end
