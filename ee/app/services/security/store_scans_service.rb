# frozen_string_literal: true

module Security
  class StoreScansService
    def initialize(build)
      @build = build
    end

    def execute
      security_reports = @build.job_artifacts.security_reports

      ActiveRecord::Base.transaction do
        security_reports.each(&method(:persist_security_report))
      end
    end

    def persist_security_report(security_report)
      Security::Scan.safe_find_or_create_by!(build: @build, pipeline: @build.pipeline, scan_type: scan_type(security_report))
    end

    def scan_type(security_report)
      Security::Scan.scan_types[security_report.file_type]
    end
  end
end
