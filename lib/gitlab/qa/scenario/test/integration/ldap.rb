require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class LDAP < Scenario::Template
            LDAP_PORT = 389
            LDAP_TLS_PORT = 636
            BASE_DN = 'dc=example,dc=org'.freeze
            BIND_DN = 'cn=admin,dc=example,dc=org'.freeze
            GROUP_BASE = 'ou=Global Groups,dc=example,dc=org'.freeze
            ADMIN_GROUP = 'AdminGroup'.freeze
            ADMIN_USER = 'admin'.freeze
            ADMIN_PASSWORD = 'admin'.freeze

            attr_reader :gitlab_name, :spec_suite, :tls, :ldap_name, :network, :orchestrate_ldap_server

            def initialize
              @ldap_name = 'ldap-server'
              @network = 'test'
            end

            def configure_omnibus(gitlab)
              raise NotImplementedError
            end

            def ldap_servers_omnibus_config
              config = YAML.safe_load <<~CFG
                main:
                  label: LDAP
                  host: #{ldap_hostname}
                  port: #{tls ? LDAP_TLS_PORT : LDAP_PORT}
                  uid: 'uid'
                  bind_dn: #{BIND_DN}
                  password: #{ADMIN_PASSWORD}
                  encryption: #{tls ? 'simple_tls' : 'plain'}
                  verify_certificates: false
                  base: #{BASE_DN}
                  user_filter: ''
                  group_base: #{GROUP_BASE}
                  admin_group: #{ADMIN_GROUP}
                  external_groups: ''
                  sync_ssh_keys: false
              CFG

              # Quotes get eaten up when the string is set in the environment
              config.to_s.gsub("\"", "\\\"")
            end

            def ldap_hostname
              "#{ldap_name}.#{network}"
            end

            def run_specs(gitlab, volumes = {}, *rspec_args)
              gitlab.instance do
                puts "Running #{spec_suite} specs!"

                Component::Specs.perform do |specs|
                  specs.suite = spec_suite
                  specs.release = gitlab.release
                  specs.network = gitlab.network
                  specs.args = [gitlab.address, *rspec_args]
                  specs.volumes = volumes
                end
              end
            end

            def orchestrate_ldap
              Component::LDAP.perform do |ldap|
                ldap.name = 'ldap-server'
                ldap.network = 'test'
                ldap.set_gitlab_credentials
                ldap.tls = tls

                ldap.instance do
                  yield
                end
              end
            end

            def perform(release, *rspec_args)
              Component::Gitlab.perform do |gitlab|
                gitlab.release = release
                gitlab.name = gitlab_name
                gitlab.network = 'test'
                gitlab.tls = tls
                configure_omnibus(gitlab)

                if orchestrate_ldap_server
                  orchestrate_ldap { run_specs(gitlab, {}, *rspec_args) }
                else
                  volumes = { 'admin': File.join(Docker::Volumes::QA_CONTAINER_WORKDIR, 'qa/fixtures/ldap/admin'),
                              'non_admin': File.join(Docker::Volumes::QA_CONTAINER_WORKDIR, 'qa/fixtures/ldap/non_admin') }
                  run_specs(gitlab, volumes, *rspec_args)
                end
              end
            end
          end
        end
      end
    end
  end
end
