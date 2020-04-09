# frozen_string_literal: true

module Gitlab
  module Unleash
    class Logger < ::Gitlab::JsonLogger
      def self.file_name_noext
        'unleash'
      end
    end
  end
end
