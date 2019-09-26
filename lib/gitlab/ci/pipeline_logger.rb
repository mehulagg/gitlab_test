# frozen_string_literal: true

module Gitlab
  module Ci
    class PipelineLogger < ::Gitlab::JsonLogger
      def self.file_name_noext
        'pipeline'
      end
    end
  end
end
