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

      vulnerabilities
    end

    private

    attr_reader :project, :filters, :vulnerabilities

    def filter_by_severities
      if filters[:severities].present?
        @vulnerabilities = vulnerabilities.with_severities(filters[:severities])
      end
    end
  end
end
