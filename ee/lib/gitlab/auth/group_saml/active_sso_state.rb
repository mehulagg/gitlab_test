# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      module ActiveSsoState
        SESSION_STORE_KEY = :active_group_sso_sign_ins

        delegate :with_store, to: :dynamic_store

        def self.dynamic_store
          @dynamic_store ||= Gitlab::DynamicStore.new(default_store: Gitlab::SessionStore.new(SESSION_STORE_KEY))
        end

        def self.update_sign_in(id, value)
          dynamic_store[id] = value
        end

        def self.sign_in_state(id)
          dynamic_store[id]
        end

        def self.clear_sign_ins
          dynamic_store.clear
        end
      end

      # module AdminMode
      #   SESSION_STORE_KEY = :admin_mode

      #   delegate :with_store, :set, :get, to: :dynamic_store

      #   def self.dynamic_store
      #     @dynamic_store ||= DynamicStore.new(default_store: SessionStore.new(SESSION_STORE_KEY))
      #   end
      # end
    end
  end
end
