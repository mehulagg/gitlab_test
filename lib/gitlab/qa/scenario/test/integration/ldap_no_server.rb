module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class LDAPNoServer < LDAP
            def initialize
              @spec_suite = 'Test::Integration::LDAPNoServer'
              @orchestrate_ldap_server = false
              @tls = false
              super
            end

            def configure_omnibus(gitlab)
              gitlab.omnibus_config = <<~OMNIBUS
                    gitlab_rails['ldap_enabled'] = true;
                    gitlab_rails['ldap_servers'] = #{ldap_servers_omnibus_config};
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
