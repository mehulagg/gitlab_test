# frozen_string_literal: true

module Gitlab
  module Auth
    class KeyStatusChecker
      include Gitlab::Utils::StrongMemoize

      def initialize(key)
        @key = key
      end

      def show_console_message?
        key_status == :expired ||
          key_status == :expires_soon
      end

      def console_message
        case key_status
        when :expired
          _('INFO: Your SSH key has expired. Please generate a new key.')
        when :expires_soon
          _('INFO: Your SSH key is expiring soon. Please generate a new key.')
        end
      end

      private

      attr_reader :key

      def key_status
        strong_memoize(:key_status) do
          if key.expired?
            :expired
          elsif key.expires_soon?
            :expires_soon
          end
        end
      end
    end
  end
end
