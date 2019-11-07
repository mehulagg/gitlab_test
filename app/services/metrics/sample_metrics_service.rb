# frozen_string_literal: true

module Metrics
  class SampleMetricsService
    DIRECTORY = "sample_metrics"

    MissingSampleMetricsFile = Class.new(StandardError)

    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
    end

    def query
      raise MissingSampleMetricsFile unless File.exist?(file_location)

      YAML.load_file(File.expand_path(file_location, __dir__))
    end

    private

    def file_location
      File.join(Rails.root, DIRECTORY, "#{identifier}.yml")
    end
  end
end
