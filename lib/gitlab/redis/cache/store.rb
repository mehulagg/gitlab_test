# frozen_string_literal: true

require 'active_support/cache'
require 'forwardable'

# loosely based on github.com/namusyaka/activesupport-cache-redis_multiplexer
module Gitlab
  module Redis
    class Cache
      class Store < ActiveSupport::Cache::Store
        extend Forwardable

        # Delegates WRITE actions into primary redis instance.
        # def_delegators :@primary, :cleanup, :clear, :decrement, :delete, :delete_matched,
        #   :increment, :write, :write_multi
        def_delegators :@primary, :write, :delete_matched, :fetch_multi, :increment, :decrement,
          :expire, :clear, :write_entry, :delete_entry

        # Constructs an instance of RedisMultiplexer.
        # @param [ActiveSupport::Cache::RedisStore] primary
        # @param [ActiveSupport::Cache::RedisStore, NilClass] read_replica
        # @return [Redis::Multiplexer]
        def initialize(primary:, read_replica: nil, **options)
          super(options)
          @primary = primary
          @read_replica = read_replica
        end

        # Triggers reconnects primary and read-replica.
        # @return [Redis::Client] The client of primary redis instance
        def reconnect
          @read_replica.reconnect if @read_replica
          @primary.reconnect
        end

        def exist?(name, options = nil)
          resolve(options).exist?(name, options)
        end

        def fetch(key, options = nil, &block)
          resolve(options).fetch(key, options, &block)
        end

        def fetch_multi(*names, &block)
          options = names.extract_options!
          names << options

          resolve(options).fetch_multi(*names, &block)
        end

        def read(key, options = nil)
          resolve(options).read(key, options)
        end

        def read_multi(*names)
          options = names.extract_options!
          names << options

          resolve(options).read_multi(*names)
        end

        private

        def resolve(options)
          if options && options[:stale_ok] && @read_replica
            @read_replica
          else
            @primary
          end
        end
      end
    end
  end
end
