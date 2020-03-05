# frozen_string_literal: true

module Gitlab
  module Auth
    class KeyStatusChecker
      include Gitlab::Utils::StrongMemoize

      def initialize(key)
        @key = key
      end

      def active?
        key_status == :active
      end

      def status_message
        case key_status
        when :expired
          _('INFO: Your SSH key has expired. Please generate a new key.')
        when :expiring_soon
          _('INFO: Your SSH key is expiring soon. Please generate a new key.')
        when :active
          _('INFO: Your SSH key is currently active.')
        end
      end

      private

      attr_reader :key

      def key_status
        strong_memoize(:key_status) do
          if key.expired?
            :expired
          elsif key.expires_soon?
            :expiring_soon
          else
            :active
          end
        end
      end
    end
  end
end
