# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class SsoState
        SESSION_STORE_KEY = :active_group_sso_sign_ins

        attr_reader :saml_provider_id

        def initialize(saml_provider_id)
          @saml_provider_id = saml_provider_id
        end

        def active?(user)
          if session_available?
            session_active?
          else
            background_sso_session?
          end
        end

        def session_active?
          active_session_data[saml_provider_id]
        end

        def background_sso_session?
          background_session_state(user)[saml_provider_id]
        end

        def update_active(value)
          active_session_data[saml_provider_id] = value
        end

        private

        def active_session_data
          Gitlab::NamespacedSessionStore.new(SESSION_STORE_KEY)
        end

        def session_available?
          active_session_data.initiated?
        end

        def self.background_session_state(user)
          combine_most_recent(all_states(user)) || {}
        end

        def self.all_states(user)
          ActiveSession.list_sessions(user)
                       .map{|session| session[SESSION_STORE_KEY.to_s]}
                       .compact
        end

        def self.combine_most_recent(sessions)
          sessions.compact.inject do |memo, session|
            memo.merge(session) do |_, first_date, second_date|
              [first_date, second_date].max
            end
          end
        end
      end
    end
  end
end
