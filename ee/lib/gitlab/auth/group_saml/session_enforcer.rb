# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class SessionEnforcer
        attr_reader :saml_provider

        def initialize(saml_provider)
          @saml_provider = saml_provider
        end

        def update_session
          ActiveSsoState.update_sign_in(saml_provider.id, DateTime.now)
        end

        def active_session?
          ActiveSsoState.sign_in_state(saml_provider.id)
        end

        def access_restricted?
          #TODO: don't check saml_session, or fix the check
          saml_enforced? && saml_session && !active_session?
        end

        def self.clear
          ActiveSsoState.clear_sign_ins
        end

        private

        def saml_enforced?
          #TODO: check license too
          saml_provider&.enforced_sso?
        end

        def group
          saml_provider&.group
        end

        def saml_session
          ActiveSsoState.dynamic_store
        end
      end
    end
  end
end
