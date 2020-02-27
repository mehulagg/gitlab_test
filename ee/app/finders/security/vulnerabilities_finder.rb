# frozen_string_literal: true

# Security::VulnerabilitiesFinder
#
# Used to filter Vulnerability records for Vulnerabilities API
#
# Arguments:
#   project: a Project to query for Vulnerabilities

module Security
  class VulnerabilitiesFinder
    def initialize(vulnerable, filters = {})
      @filters = filters
      @vulnerabilities = vulnerable.vulnerabilities
    end

    def execute
      filter_by_projects
      filter_by_report_types
      filter_by_severities
      filter_by_states

      vulnerabilities
    end

    private

    attr_reader :filters, :vulnerabilities

    def filter_by_projects
      if filters[:project_ids].present?
        @vulnerabilities = vulnerabilities.for_projects(filters[:project_ids])
      end
    end

    def filter_by_report_types
      if filters[:report_types].present?
        @vulnerabilities = vulnerabilities.with_report_types(filters[:report_types])
      end
    end

    def filter_by_severities
      if filters[:severities].present?
        @vulnerabilities = vulnerabilities.with_severities(filters[:severities])
      end
    end

    def filter_by_states
      if filters[:states].present?
        @vulnerabilities = vulnerabilities.with_states(filters[:states])
      end
    end
  end
end
