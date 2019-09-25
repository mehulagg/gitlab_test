require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class LDAPTLS < LDAP
            def initialize
              @gitlab_name = 'gitlab'
              @spec_suite = 'Test::Integration::LDAPTLS'
              @orchestrate_ldap_server = true
              @tls = true
              super
            end

            def set_accept_insecure_certs
              ::Gitlab::QA::Runtime::Env.accept_insecure_certs = 'true'
            end

            def configure_omnibus(gitlab)
              set_accept_insecure_certs
              gitlab.omnibus_config = <<~OMNIBUS
                    gitlab_rails['ldap_enabled'] = true;
                    gitlab_rails['ldap_servers'] = #{ldap_servers_omnibus_config};
                    letsencrypt['enable'] = false;
                    external_url '#{gitlab.address}';
                    gitlab_rails['ldap_sync_worker_cron'] = '* * * * *';
                    gitlab_rails['ldap_group_sync_worker_cron'] = '* * * * *';
              OMNIBUS
            end
          end
        end
      end
    end
  end
end
