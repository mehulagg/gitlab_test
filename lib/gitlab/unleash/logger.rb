# frozen_string_literal: true

module Gitlab
  module Unleash
    class Logger < ::Gitlab::JsonLogger
      def self.file_name_noext
        'unleash'
      end

      def self.level=(level)
        # no-op, otherwise `Unleash.logger.level` causes NotImplementedError.
      end

      def self.build
        super.tap { |logger| logger.level = Rails.logger.level } # rubocop:disable Gitlab/RailsLogger
      end
    end
  end
end
