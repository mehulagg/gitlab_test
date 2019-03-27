# frozen_string_literal: true

module Gitlab
  class SessionStore
    STORE_KEY = :session_storage

    class << self
      #Sets the session in the store and then cleans it up
      def with_session(session)
        #TODO: Could there be a negative interaction between Thread.current and
        #      RequestStore here? Should we just stick to Thread.current ?
        old = self.current
        self.current = session
        yield
      ensure
        self.current = old
      end

      def current
        store[STORE_KEY]
      end

      protected

      def current=(value)
        store[STORE_KEY] = value
      end

      def store
        if RequestStore.active?
          RequestStore
        else
          Thread.current
        end
      end
    end

    delegate :[], :[]=, to: :store

    def initialize(key)
      @key = key
    end

    def store
      SessionStore.current[@key] ||= {}
      SessionStore.current[@key]
    end
  end
end
