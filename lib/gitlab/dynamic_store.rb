# frozen_string_literal: true

module Gitlab
  class DynamicStore
    delegate :set, :get, to: :store

    def initialize(default_store: nil)
      @default_store = default_store
    end

    def store
      @store || @default_store
    end

    def store=(value)
      @store = value
    end

    def with_store(store)
      old = @store
      @store = store
      yield
    ensure
      @store = old
    end
  end
end
