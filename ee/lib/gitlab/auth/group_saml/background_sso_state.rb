# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class BackgroundSsoState
        attr_reader :user

        def initialize(user)
          @user = user
        end

        def all
          sessions = ActiveSession.list_sessions(user)
          key = SsoState::SESSION_STORE_KEY
          sessions.map { |session| session[key.to_s] }.compact
        end

        def most_recent(saml_provider_id)
          all.map { |session| session[saml_provider_id] }.max
        end
      end
    end
  end
end
