# frozen_string_literal: true

module Gitlab
  module Auth
    module SAML
      class Config
        prepend_if_ee('::EE::Gitlab::Auth::SAML::Config') # rubocop: disable Cop/InjectEnterpriseEditionModule

        class << self
          def options
            Gitlab::Auth::OAuth::Provider.config_for('saml')
          end

          def upstream_two_factor_authn_contexts
            options.args[:upstream_two_factor_authn_contexts]
          end

          def groups
            options[:groups_attribute]
          end

          def external_groups
            options[:external_groups]
          end

          def admin_groups
            options[:admin_groups]
          end
        end
      end
    end
  end
end
