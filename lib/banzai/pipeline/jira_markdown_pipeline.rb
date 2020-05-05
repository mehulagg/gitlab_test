# frozen_string_literal: true

module Banzai
  module Pipeline
    class JiraMarkdownPipeline < BasePipeline
      def self.filters
        FilterArray[
          Filter::JiraMarkdownToCommonmarkFilter
        ]
      end
    end
  end
end
