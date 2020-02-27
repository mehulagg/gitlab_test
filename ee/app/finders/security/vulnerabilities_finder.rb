# frozen_string_literal: true

# Security::VulnerabilitiesFinder
#
# Used to filter Vulnerability records for Vulnerabilities API
#
# Arguments:
#   project: a Project to query for Vulnerabilities

module Security
  class VulnerabilitiesFinder
    def initialize(project, filters = {})
      @filters = filters
      @vulnerabilities = project.vulnerabilities
    end

    def execute
      filter_by_severities
      filter_by_report_types

      vulnerabilities
    end

    private

    attr_reader :filters, :vulnerabilities

    def filter_by_severities
      if filters[:severities].present?
        @vulnerabilities = vulnerabilities.with_severities(filters[:severities])
      end
    end

    def filter_by_report_types
      if filters[:report_types].present?
        @vulnerabilities = vulnerabilities.with_report_types(filters[:report_types])
      end
    end
  end
end
