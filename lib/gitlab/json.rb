# frozen_string_literal: true

module Gitlab
  module Json
    class << self
      def parse(*args, legacy_mode: true)
        data = adapter.parse(*args)

        raise parser_error if legacy_mode && [String, TrueClass, FalseClass].any? { |type| data.is_a?(type) }

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
        ::JSON
      end

      def parser_error
        ::JSON::ParserError
      end
    end
  end
end
