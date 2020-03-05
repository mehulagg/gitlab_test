# frozen_string_literal: true

module Types
  class VulnerabilitiesSummaryType < BaseObject
    graphql_name 'VulnerabilitiesSummary'
    description 'Represents vulnerability counts by severity'

    authorize :read_vulnerability

    DEFAULT_SEVERITY_COUNT = 0
    VULNERABILITY_SEVERITIES = ::Vulnerabilities::Occurrence::SEVERITY_LEVELS.keys.freeze

    VULNERABILITY_SEVERITIES.each do |severity|
      field severity, GraphQL::INT_TYPE, null: true,
            description: "Number of vulnerabilities of #{severity.upcase} severity of the project",
            resolve: -> (obj, _args, _ctx) { obj.public_send(severity) || 0 } # rubocop: disable GitlabSecurity/PublicSend. See https://gitlab.com/gitlab-org/gitlab/issues/208837
    end
  end
end
