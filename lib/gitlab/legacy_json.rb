# frozen_string_literal: true

module Gitlab
  module LegacyJson
    class << self
      def parse(*args)
        data = adapter.parse(*args)

        raise JSON::ParserError if data.is_a?(String)

        data
      end

      def parse!(*args)
        adapter.parse!(*args)
      end

      def dump(*args)
        adapter.dump(*args)
      end

      private

      def adapter
        @adapter ||= ::JSON
      end
    end
  end
end
