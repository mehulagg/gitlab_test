# frozen_string_literal: true

module Resolvers
  class VulnerabilitiesResolver < VulnerabilitiesBaseResolver
    include Gitlab::Utils::StrongMemoize

    type Types::VulnerabilityType, null: true

    argument :project_id, [GraphQL::ID_TYPE],
             required: false,
             description: 'Filter vulnerabilities by project'

    argument :report_type, [Types::VulnerabilityReportTypeEnum],
             required: false,
             description: 'Filter vulnerabilities by report type'

    argument :severity, [Types::VulnerabilitySeverityEnum],
             required: false,
             description: 'Filter vulnerabilities by severity'

    argument :state, [Types::VulnerabilityStateEnum],
             required: false,
             description: 'Filter vulnerabilities by state'

    argument :scanner, [GraphQL::STRING_TYPE],
             required: false,
             description: 'Filter vulnerabilities by scanner'

    argument :sort, Types::VulnerabilitySortEnum,
             required: false,
             default_value: 'severity_desc',
             description: 'List vulnerabilities by sort order'

    argument :has_resolution, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Returns only the vulnerabilities which have been resolved on default branch'

    argument :has_issues, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Returns only the vulnerabilities which have linked issues'

    def resolve(**args)
      return Vulnerability.none unless vulnerable

      vulnerabilities(args)
        .with_findings_scanner_and_identifiers
        .with_created_issue_links_and_issues
    end

    private

    def vulnerabilities(params)
      Security::VulnerabilitiesFinder.new(vulnerable, params).execute
    end
  end
end
