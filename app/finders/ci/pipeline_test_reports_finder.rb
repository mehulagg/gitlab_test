# frozen_string_literal: true

module Ci
  class PipelineTestReportsFinder
    include Gitlab::Utils::StrongMemoize

    attr_reader :pipeline, :test_reports

    def initialize(pipeline)
      @pipeline = pipeline
      strong_memoize(:test_reports) do
        pipeline.test_reports
      rescue Gitlab::Ci::Parsers::ParserError
        :error
      end
    end

    def execute(scope: nil)
      @test_reports
    end
  end
end
