# frozen_string_literal: true

module Security
  # Service for counting the number of scanned resources for
  # an array of report types within a pipeline
  #
  class ScannedResourcesService
    # @param [Ci::Pipeline] pipeline
    # @param Array[Symbol] report_types Summary report types. Valid values are members of Vulnerabilities::Occurrence::REPORT_TYPES
    def initialize(pipeline, report_types)
      @pipeline = pipeline
      @report_types = report_types
    end

    def execute
      reports = @pipeline&.security_reports&.reports
      @report_types.each_with_object({}) do |type, acc|
        scanned_resources = reports.fetch(type)&.scanned_resources
        scanned_resources.each { |r| r['request_method'] = r['method'] }
        acc[type] = scanned_resources
      end
    end
  end
end
