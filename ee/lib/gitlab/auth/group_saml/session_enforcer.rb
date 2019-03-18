# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class SessionEnforcer
        SESSION_KEY = :group_saml_sign_ins

        attr_reader :saml_provider

        def initialize(session, saml_provider)
          @session = session
          @saml_provider = saml_provider
        end

        def update_session
          saml_session[saml_provider.id] = DateTime.now
        end

        def active_session?
          saml_session[saml_provider.id]
        end

        def access_restricted?
          saml_enforced? && @session && !active_session?
        end

        def self.clear(session)
          session.delete(SESSION_KEY)
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
          @session[SESSION_KEY] ||= {}
        end
      end
    end
  end
end
