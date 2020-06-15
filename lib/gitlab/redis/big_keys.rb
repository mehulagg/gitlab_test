# frozen_string_literal: true

module Gitlab
  module Redis
    class BigKeys
      TYPES = %i[string list set zset hash stream].freeze

      def initialize(redis)
        @redis = redis
      end

      def report
        result = {
          biggest: { by_elements: {}, by_bytes: {} },
          summary: {}
        }
        TYPES.each do |type|
          result[:summary][type] = { sampled_count: 0, total_elements: 0, total_bytes: 0 }
        end

        scan_batch do |keys|
          types = key_types(keys)
          elements = key_elements(keys, types)
          bytes = key_bytes(keys)

          keys.zip(types, elements, bytes) do |key, type, num_elements, num_bytes|
            next unless type && num_elements && num_bytes

            result[:biggest][:by_elements][type] ||= { elements: -1 }
            if result[:biggest][:by_elements][type][:elements] < num_elements
              result[:biggest][:by_elements][type] = { key: json_safe(key), elements: num_elements }
            end

            result[:biggest][:by_bytes][type] ||= { bytes: -1 }
            if result[:biggest][:by_bytes][type][:bytes] < num_bytes
              result[:biggest][:by_bytes][type] = { key: json_safe(key), bytes: num_bytes }
            end

            result[:summary][type][:sampled_count] += 1
            result[:summary][type][:total_elements] += num_elements
            result[:summary][type][:total_bytes] += num_bytes
          end
        end

        result
      end

      private

      attr_reader :redis

      def scan_batch
        start = '0'
        cursor = start

        loop do
          cursor, keys = redis.scan(cursor)
          yield keys
          break if cursor == start
        end
      end

      def key_types(keys)
        result = redis.pipelined do |redis|
          keys.each { |key| redis.type(key) }
        end

        result.map { |t| t&.to_sym }
      end

      SIZE_COMMANDS = {
        string: :strlen,
        list: :llen,
        set: :scard,
        zset: :zcard,
        hash: :hlen,
        stream: :xlen
      }.freeze

      def key_elements(keys, types)
        redis.pipelined do |redis|
          keys.zip(types) do |key, type|
            redis.call(SIZE_COMMANDS.fetch(type), key)
          end
        end
      end

      def key_bytes(keys)
        redis.pipelined do |redis|
          keys.each { |key| redis.call('memory', 'usage', key) }
        end
      end

      def json_safe(string)
        string.encode('utf-8', invalid: :replace)
      end
    end
  end
end
